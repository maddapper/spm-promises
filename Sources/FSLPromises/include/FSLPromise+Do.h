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

@interface FSLPromise<Value>(DoAdditions)

typedef id __nullable (^FSLPromiseDoWorkBlock)(void) NS_SWIFT_UNAVAILABLE("");

/**
 Creates a pending promise and executes `work` block asynchronously.

 @param work A block that returns a value or an error used to resolve the promise.
 @return A new pending promise.
 */
+ (instancetype)do:(FSLPromiseDoWorkBlock)work NS_SWIFT_UNAVAILABLE("");

/**
 Creates a pending promise and executes `work` block asynchronously on the given queue.

 @param queue A queue to invoke the `work` block on.
 @param work A block that returns a value or an error used to resolve the promise.
 @return A new pending promise.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue do:(FSLPromiseDoWorkBlock)work NS_REFINED_FOR_SWIFT;

@end

/**
 Convenience dot-syntax wrappers for `FSLPromise` `do` operators.
 Usage: FSLPromise.doOn(queue, ^(NSError *error) { ... })
 */
@interface FSLPromise<Value>(DotSyntax_DoAdditions)

+ (FSLPromise * (^)(dispatch_queue_t, FSLPromiseDoWorkBlock))doOn FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
