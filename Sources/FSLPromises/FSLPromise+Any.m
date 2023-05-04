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

#import "FSLPromise+Any.h"

#import "FSLPromise+Async.h"
#import "FSLPromisePrivate.h"

static NSArray *FSLPromiseCombineValuesAndErrors(NSArray<FSLPromise *> *promises) {
  NSMutableArray *combinedValuesAndErrors = [[NSMutableArray alloc] init];
  for (FSLPromise *promise in promises) {
    if (promise.isFulfilled) {
      [combinedValuesAndErrors addObject:promise.value ?: [NSNull null]];
      continue;
    }
    if (promise.isRejected) {
      [combinedValuesAndErrors addObject:promise.error];
      continue;
    }
    assert(!promise.isPending);
  };
  return combinedValuesAndErrors;
}

@implementation FSLPromise (AnyAdditions)

+ (FSLPromise<NSArray *> *)any:(NSArray *)promises {
  return [self onQueue:FSLPromise.defaultDispatchQueue any:promises];
}

+ (FSLPromise<NSArray *> *)onQueue:(dispatch_queue_t)queue any:(NSArray *)anyPromises {
  NSParameterAssert(queue);
  NSParameterAssert(anyPromises);

  if (anyPromises.count == 0) {
    return [[self alloc] initWithResolution:@[]];
  }
  NSMutableArray *promises = [anyPromises mutableCopy];
  return [self
      onQueue:queue
        async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
          for (NSUInteger i = 0; i < promises.count; ++i) {
            id promise = promises[i];
            if ([promise isKindOfClass:self]) {
              continue;
            } else {
              [promises replaceObjectAtIndex:i
                                  withObject:[[self alloc] initWithResolution:promise]];
            }
          }
          for (FSLPromise *promise in promises) {
            [promise observeOnQueue:queue
                fulfill:^(id __unused _) {
                  // Wait until all are resolved.
                  for (FSLPromise *promise in promises) {
                    if (promise.isPending) {
                      return;
                    }
                  }
                  // If called multiple times, only the first one affects the result.
                  fulfill(FSLPromiseCombineValuesAndErrors(promises));
                }
                reject:^(NSError *error) {
                  BOOL atLeastOneIsFulfilled = NO;
                  for (FSLPromise *promise in promises) {
                    if (promise.isPending) {
                      return;
                    }
                    if (promise.isFulfilled) {
                      atLeastOneIsFulfilled = YES;
                    }
                  }
                  if (atLeastOneIsFulfilled) {
                    fulfill(FSLPromiseCombineValuesAndErrors(promises));
                  } else {
                    reject(error);
                  }
                }];
          }
        }];
}

@end

@implementation FSLPromise (DotSyntax_AnyAdditions)

+ (FSLPromise<NSArray *> * (^)(NSArray *))any {
  return ^(NSArray *promises) {
    return [self any:promises];
  };
}

+ (FSLPromise<NSArray *> * (^)(dispatch_queue_t, NSArray *))anyOn {
  return ^(dispatch_queue_t queue, NSArray *promises) {
    return [self onQueue:queue any:promises];
  };
}

@end
