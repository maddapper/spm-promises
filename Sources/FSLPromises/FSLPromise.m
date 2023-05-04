/**
 Copyright 2018 Google Inc. All rights reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "FSLPromisePrivate.h"

/** All states a promise can be in. */
typedef NS_ENUM(NSInteger, FSLPromiseState) {
  FSLPromiseStatePending = 0,
  FSLPromiseStateFulfilled,
  FSLPromiseStateRejected,
};

typedef void (^FSLPromiseObserver)(FSLPromiseState state, id __nullable resolution);

static dispatch_queue_t gFSLPromiseDefaultDispatchQueue;

@implementation FSLPromise {
  /** Current state of the promise. */
  FSLPromiseState _state;
  /**
   Set of arbitrary objects to keep strongly while the promise is pending.
   Becomes nil after the promise has been resolved.
   */
  NSMutableSet *__nullable _pendingObjects;
  /**
   Value to fulfill the promise with.
   Can be nil if the promise is still pending, was resolved with nil or after it has been rejected.
   */
  id __nullable _value;
  /**
   Error to reject the promise with.
   Can be nil if the promise is still pending or after it has been fulfilled.
   */
  NSError *__nullable _error;
  /** List of observers to notify when the promise gets resolved. */
  NSMutableArray<FSLPromiseObserver> *_observers;
}

+ (void)initialize {
  if (self == [FSLPromise class]) {
    gFSLPromiseDefaultDispatchQueue = dispatch_get_main_queue();
  }
}

+ (dispatch_queue_t)defaultDispatchQueue {
  @synchronized(self) {
    return gFSLPromiseDefaultDispatchQueue;
  }
}

+ (void)setDefaultDispatchQueue:(dispatch_queue_t)queue {
  NSParameterAssert(queue);

  @synchronized(self) {
    gFSLPromiseDefaultDispatchQueue = queue;
  }
}

+ (instancetype)pendingPromise {
  return [[self alloc] initPending];
}

+ (instancetype)resolvedWith:(nullable id)resolution {
  return [[self alloc] initWithResolution:resolution];
}

- (void)fulfill:(nullable id)value {
  if ([value isKindOfClass:[NSError class]]) {
    [self reject:(NSError *)value];
  } else {
    @synchronized(self) {
      if (_state == FSLPromiseStatePending) {
        _state = FSLPromiseStateFulfilled;
        _value = value;
        _pendingObjects = nil;
        for (FSLPromiseObserver observer in _observers) {
          observer(_state, _value);
        }
        _observers = nil;
        dispatch_group_leave(FSLPromise.dispatchGroup);
      }
    }
  }
}

- (void)reject:(NSError *)error {
  NSAssert([error isKindOfClass:[NSError class]], @"Invalid error type.");

  if (![error isKindOfClass:[NSError class]]) {
    // Give up on invalid error type in Release mode.
    @throw error;  // NOLINT
  }
  @synchronized(self) {
    if (_state == FSLPromiseStatePending) {
      _state = FSLPromiseStateRejected;
      _error = error;
      _pendingObjects = nil;
      for (FSLPromiseObserver observer in _observers) {
        observer(_state, _error);
      }
      _observers = nil;
      dispatch_group_leave(FSLPromise.dispatchGroup);
    }
  }
}

#pragma mark - NSObject

- (NSString *)description {
  if (self.isFulfilled) {
    return [NSString stringWithFormat:@"<%@ %p> Fulfilled: %@", NSStringFromClass([self class]),
                                      self, self.value];
  }
  if (self.isRejected) {
    return [NSString stringWithFormat:@"<%@ %p> Rejected: %@", NSStringFromClass([self class]),
                                      self, self.error];
  }
  return [NSString stringWithFormat:@"<%@ %p> Pending", NSStringFromClass([self class]), self];
}

#pragma mark - Private

- (instancetype)initPending {
  self = [super init];
  if (self) {
    dispatch_group_enter(FSLPromise.dispatchGroup);
  }
  return self;
}

- (instancetype)initWithResolution:(nullable id)resolution {
  self = [super init];
  if (self) {
    if ([resolution isKindOfClass:[NSError class]]) {
      _state = FSLPromiseStateRejected;
      _error = (NSError *)resolution;
    } else {
      _state = FSLPromiseStateFulfilled;
      _value = resolution;
    }
  }
  return self;
}

- (void)dealloc {
  if (_state == FSLPromiseStatePending) {
    dispatch_group_leave(FSLPromise.dispatchGroup);
  }
}

- (BOOL)isPending {
  @synchronized(self) {
    return _state == FSLPromiseStatePending;
  }
}

- (BOOL)isFulfilled {
  @synchronized(self) {
    return _state == FSLPromiseStateFulfilled;
  }
}

- (BOOL)isRejected {
  @synchronized(self) {
    return _state == FSLPromiseStateRejected;
  }
}

- (nullable id)value {
  @synchronized(self) {
    return _value;
  }
}

- (NSError *__nullable)error {
  @synchronized(self) {
    return _error;
  }
}

- (void)addPendingObject:(id)object {
  NSParameterAssert(object);

  @synchronized(self) {
    if (_state == FSLPromiseStatePending) {
      if (!_pendingObjects) {
        _pendingObjects = [[NSMutableSet alloc] init];
      }
      [_pendingObjects addObject:object];
    }
  }
}

- (void)observeOnQueue:(dispatch_queue_t)queue
               fulfill:(FSLPromiseOnFulfillBlock)onFulfill
                reject:(FSLPromiseOnRejectBlock)onReject {
  NSParameterAssert(queue);
  NSParameterAssert(onFulfill);
  NSParameterAssert(onReject);

  @synchronized(self) {
    switch (_state) {
      case FSLPromiseStatePending: {
        if (!_observers) {
          _observers = [[NSMutableArray alloc] init];
        }
        [_observers addObject:^(FSLPromiseState state, id __nullable resolution) {
          dispatch_group_async(FSLPromise.dispatchGroup, queue, ^{
            switch (state) {
              case FSLPromiseStatePending:
                break;
              case FSLPromiseStateFulfilled:
                onFulfill(resolution);
                break;
              case FSLPromiseStateRejected:
                onReject(resolution);
                break;
            }
          });
        }];
        break;
      }
      case FSLPromiseStateFulfilled: {
        dispatch_group_async(FSLPromise.dispatchGroup, queue, ^{
          onFulfill(self->_value);
        });
        break;
      }
      case FSLPromiseStateRejected: {
        dispatch_group_async(FSLPromise.dispatchGroup, queue, ^{
          onReject(self->_error);
        });
        break;
      }
    }
  }
}

- (FSLPromise *)chainOnQueue:(dispatch_queue_t)queue
              chainedFulfill:(FSLPromiseChainedFulfillBlock)chainedFulfill
               chainedReject:(FSLPromiseChainedRejectBlock)chainedReject {
  NSParameterAssert(queue);

  FSLPromise *promise = [[[self class] alloc] initPending];
  __auto_type resolver = ^(id __nullable value) {
    if ([value isKindOfClass:[FSLPromise class]]) {
      [(FSLPromise *)value observeOnQueue:queue
          fulfill:^(id __nullable value) {
            [promise fulfill:value];
          }
          reject:^(NSError *error) {
            [promise reject:error];
          }];
    } else {
      [promise fulfill:value];
    }
  };
  [self observeOnQueue:queue
      fulfill:^(id __nullable value) {
        value = chainedFulfill ? chainedFulfill(value) : value;
        resolver(value);
      }
      reject:^(NSError *error) {
        id value = chainedReject ? chainedReject(error) : error;
        resolver(value);
      }];
  return promise;
}

@end

@implementation FSLPromise (DotSyntaxAdditions)

+ (instancetype (^)(void))pending {
  return ^(void) {
    return [self pendingPromise];
  };
}

+ (instancetype (^)(id __nullable))resolved {
  return ^(id resolution) {
    return [self resolvedWith:resolution];
  };
}

@end
