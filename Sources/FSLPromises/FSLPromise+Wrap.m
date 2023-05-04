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

#import "FSLPromise+Wrap.h"

#import "FSLPromise+Async.h"

@implementation FSLPromise (WrapAdditions)

+ (instancetype)wrapCompletion:(void (^)(FSLPromiseCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapCompletion:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
         wrapCompletion:(void (^)(FSLPromiseCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
                   work(^{
                     fulfill(nil);
                   });
                 }];
}

+ (instancetype)wrapObjectCompletion:(void (^)(FSLPromiseObjectCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapObjectCompletion:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapObjectCompletion:(void (^)(FSLPromiseObjectCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
                   work(^(id __nullable value) {
                     fulfill(value);
                   });
                 }];
}

+ (instancetype)wrapErrorCompletion:(void (^)(FSLPromiseErrorCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapErrorCompletion:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapErrorCompletion:(void (^)(FSLPromiseErrorCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(NSError *__nullable error) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(nil);
                     }
                   });
                 }];
}

+ (instancetype)wrapObjectOrErrorCompletion:(void (^)(FSLPromiseObjectOrErrorCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapObjectOrErrorCompletion:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapObjectOrErrorCompletion:(void (^)(FSLPromiseObjectOrErrorCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(id __nullable value, NSError *__nullable error) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(value);
                     }
                   });
                 }];
}

+ (instancetype)wrapErrorOrObjectCompletion:(void (^)(FSLPromiseErrorOrObjectCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapErrorOrObjectCompletion:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapErrorOrObjectCompletion:(void (^)(FSLPromiseErrorOrObjectCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(NSError *__nullable error, id __nullable value) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(value);
                     }
                   });
                 }];
}

+ (FSLPromise<NSArray *> *)wrap2ObjectsOrErrorCompletion:
    (void (^)(FSLPromise2ObjectsOrErrorCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrap2ObjectsOrErrorCompletion:work];
}

+ (FSLPromise<NSArray *> *)onQueue:(dispatch_queue_t)queue
     wrap2ObjectsOrErrorCompletion:(void (^)(FSLPromise2ObjectsOrErrorCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(id __nullable value1, id __nullable value2, NSError *__nullable error) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(@[ value1 ?: [NSNull null], value2 ?: [NSNull null] ]);
                     }
                   });
                 }];
}

+ (FSLPromise<NSNumber *> *)wrapBoolCompletion:(void (^)(FSLPromiseBoolCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapBoolCompletion:work];
}

+ (FSLPromise<NSNumber *> *)onQueue:(dispatch_queue_t)queue
                 wrapBoolCompletion:(void (^)(FSLPromiseBoolCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
                   work(^(BOOL value) {
                     fulfill(@(value));
                   });
                 }];
}

+ (FSLPromise<NSNumber *> *)wrapBoolOrErrorCompletion:
    (void (^)(FSLPromiseBoolOrErrorCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapBoolOrErrorCompletion:work];
}

+ (FSLPromise<NSNumber *> *)onQueue:(dispatch_queue_t)queue
          wrapBoolOrErrorCompletion:(void (^)(FSLPromiseBoolOrErrorCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(BOOL value, NSError *__nullable error) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(@(value));
                     }
                   });
                 }];
}

+ (FSLPromise<NSNumber *> *)wrapIntegerCompletion:(void (^)(FSLPromiseIntegerCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapIntegerCompletion:work];
}

+ (FSLPromise<NSNumber *> *)onQueue:(dispatch_queue_t)queue
              wrapIntegerCompletion:(void (^)(FSLPromiseIntegerCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
                   work(^(NSInteger value) {
                     fulfill(@(value));
                   });
                 }];
}

+ (FSLPromise<NSNumber *> *)wrapIntegerOrErrorCompletion:
    (void (^)(FSLPromiseIntegerOrErrorCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapIntegerOrErrorCompletion:work];
}

+ (FSLPromise<NSNumber *> *)onQueue:(dispatch_queue_t)queue
       wrapIntegerOrErrorCompletion:(void (^)(FSLPromiseIntegerOrErrorCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(NSInteger value, NSError *__nullable error) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(@(value));
                     }
                   });
                 }];
}

+ (FSLPromise<NSNumber *> *)wrapDoubleCompletion:(void (^)(FSLPromiseDoubleCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapDoubleCompletion:work];
}

+ (FSLPromise<NSNumber *> *)onQueue:(dispatch_queue_t)queue
               wrapDoubleCompletion:(void (^)(FSLPromiseDoubleCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:(dispatch_queue_t)queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
                   work(^(double value) {
                     fulfill(@(value));
                   });
                 }];
}

+ (FSLPromise<NSNumber *> *)wrapDoubleOrErrorCompletion:
    (void (^)(FSLPromiseDoubleOrErrorCompletion))work {
  return [self onQueue:self.defaultDispatchQueue wrapDoubleOrErrorCompletion:work];
}

+ (FSLPromise<NSNumber *> *)onQueue:(dispatch_queue_t)queue
        wrapDoubleOrErrorCompletion:(void (^)(FSLPromiseDoubleOrErrorCompletion))work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self onQueue:queue
                 async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) {
                   work(^(double value, NSError *__nullable error) {
                     if (error) {
                       reject(error);
                     } else {
                       fulfill(@(value));
                     }
                   });
                 }];
}

@end

@implementation FSLPromise (DotSyntax_WrapAdditions)

+ (FSLPromise * (^)(void (^)(FSLPromiseCompletion)))wrapCompletion {
  return ^(void (^work)(FSLPromiseCompletion)) {
    return [self wrapCompletion:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t, void (^)(FSLPromiseCompletion)))wrapCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseCompletion)) {
    return [self onQueue:queue wrapCompletion:work];
  };
}

+ (FSLPromise * (^)(void (^)(FSLPromiseObjectCompletion)))wrapObjectCompletion {
  return ^(void (^work)(FSLPromiseObjectCompletion)) {
    return [self wrapObjectCompletion:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t, void (^)(FSLPromiseObjectCompletion)))wrapObjectCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseObjectCompletion)) {
    return [self onQueue:queue wrapObjectCompletion:work];
  };
}

+ (FSLPromise * (^)(void (^)(FSLPromiseErrorCompletion)))wrapErrorCompletion {
  return ^(void (^work)(FSLPromiseErrorCompletion)) {
    return [self wrapErrorCompletion:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t, void (^)(FSLPromiseErrorCompletion)))wrapErrorCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseErrorCompletion)) {
    return [self onQueue:queue wrapErrorCompletion:work];
  };
}

+ (FSLPromise * (^)(void (^)(FSLPromiseObjectOrErrorCompletion)))wrapObjectOrErrorCompletion {
  return ^(void (^work)(FSLPromiseObjectOrErrorCompletion)) {
    return [self wrapObjectOrErrorCompletion:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t,
                    void (^)(FSLPromiseObjectOrErrorCompletion)))wrapObjectOrErrorCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseObjectOrErrorCompletion)) {
    return [self onQueue:queue wrapObjectOrErrorCompletion:work];
  };
}

+ (FSLPromise * (^)(void (^)(FSLPromiseErrorOrObjectCompletion)))wrapErrorOrObjectCompletion {
  return ^(void (^work)(FSLPromiseErrorOrObjectCompletion)) {
    return [self wrapErrorOrObjectCompletion:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t,
                    void (^)(FSLPromiseErrorOrObjectCompletion)))wrapErrorOrObjectCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseErrorOrObjectCompletion)) {
    return [self onQueue:queue wrapErrorOrObjectCompletion:work];
  };
}

+ (FSLPromise<NSArray *> * (^)(void (^)(FSLPromise2ObjectsOrErrorCompletion)))
    wrap2ObjectsOrErrorCompletion {
  return ^(void (^work)(FSLPromise2ObjectsOrErrorCompletion)) {
    return [self wrap2ObjectsOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSArray *> * (^)(dispatch_queue_t, void (^)(FSLPromise2ObjectsOrErrorCompletion)))
    wrap2ObjectsOrErrorCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromise2ObjectsOrErrorCompletion)) {
    return [self onQueue:queue wrap2ObjectsOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(void (^)(FSLPromiseBoolCompletion)))wrapBoolCompletion {
  return ^(void (^work)(FSLPromiseBoolCompletion)) {
    return [self wrapBoolCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(dispatch_queue_t,
                                void (^)(FSLPromiseBoolCompletion)))wrapBoolCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseBoolCompletion)) {
    return [self onQueue:queue wrapBoolCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(void (^)(FSLPromiseBoolOrErrorCompletion)))
    wrapBoolOrErrorCompletion {
  return ^(void (^work)(FSLPromiseBoolOrErrorCompletion)) {
    return [self wrapBoolOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(dispatch_queue_t, void (^)(FSLPromiseBoolOrErrorCompletion)))
    wrapBoolOrErrorCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseBoolOrErrorCompletion)) {
    return [self onQueue:queue wrapBoolOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(void (^)(FSLPromiseIntegerCompletion)))wrapIntegerCompletion {
  return ^(void (^work)(FSLPromiseIntegerCompletion)) {
    return [self wrapIntegerCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(dispatch_queue_t,
                                void (^)(FSLPromiseIntegerCompletion)))wrapIntegerCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseIntegerCompletion)) {
    return [self onQueue:queue wrapIntegerCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(void (^)(FSLPromiseIntegerOrErrorCompletion)))
    wrapIntegerOrErrorCompletion {
  return ^(void (^work)(FSLPromiseIntegerOrErrorCompletion)) {
    return [self wrapIntegerOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(dispatch_queue_t, void (^)(FSLPromiseIntegerOrErrorCompletion)))
    wrapIntegerOrErrorCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseIntegerOrErrorCompletion)) {
    return [self onQueue:queue wrapIntegerOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(void (^)(FSLPromiseDoubleCompletion)))wrapDoubleCompletion {
  return ^(void (^work)(FSLPromiseDoubleCompletion)) {
    return [self wrapDoubleCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(dispatch_queue_t,
                                void (^)(FSLPromiseDoubleCompletion)))wrapDoubleCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseDoubleCompletion)) {
    return [self onQueue:queue wrapDoubleCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(void (^)(FSLPromiseDoubleOrErrorCompletion)))
    wrapDoubleOrErrorCompletion {
  return ^(void (^work)(FSLPromiseDoubleOrErrorCompletion)) {
    return [self wrapDoubleOrErrorCompletion:work];
  };
}

+ (FSLPromise<NSNumber *> * (^)(dispatch_queue_t, void (^)(FSLPromiseDoubleOrErrorCompletion)))
    wrapDoubleOrErrorCompletionOn {
  return ^(dispatch_queue_t queue, void (^work)(FSLPromiseDoubleOrErrorCompletion)) {
    return [self onQueue:queue wrapDoubleOrErrorCompletion:work];
  };
}

@end
