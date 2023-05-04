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

#import "FSLPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSLPromise<Value>(AsyncAdditions)

typedef void (^FSLPromiseFulfillBlock)(Value __nullable value) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseRejectBlock)(NSError *error) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseAsyncWorkBlock)(FSLPromiseFulfillBlock fulfill,
                                         FSLPromiseRejectBlock reject) NS_SWIFT_UNAVAILABLE("");

/**
 Creates a pending promise and executes `work` block asynchronously.

 @param work A block to perform any operations needed to resolve the promise.
 @return A new pending promise.
 */
+ (instancetype)async:(FSLPromiseAsyncWorkBlock)work NS_SWIFT_UNAVAILABLE("");

/**
 Creates a pending promise and executes `work` block asynchronously on the given queue.

 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @return A new pending promise.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue
                  async:(FSLPromiseAsyncWorkBlock)work NS_REFINED_FOR_SWIFT;

@end

/**
 Convenience dot-syntax wrappers for `FSLPromise` `async` operators.
 Usage: FSLPromise.async(^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock reject) { ... })
 */
@interface FSLPromise<Value>(DotSyntax_AsyncAdditions)

+ (FSLPromise* (^)(FSLPromiseAsyncWorkBlock))async FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(dispatch_queue_t, FSLPromiseAsyncWorkBlock))asyncOn FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
