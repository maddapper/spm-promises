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

@interface FSLPromise<Value>(AlwaysAdditions)

typedef void (^FSLPromiseAlwaysWorkBlock)(void) NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block that always executes, no matter if the receiver is rejected or fulfilled.
 @return A new pending promise to be resolved with same resolution as the receiver.
 */
- (FSLPromise *)always:(FSLPromiseAlwaysWorkBlock)work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to dispatch on.
 @param work A block that always executes, no matter if the receiver is rejected or fulfilled.
 @return A new pending promise to be resolved with same resolution as the receiver.
 */
- (FSLPromise *)onQueue:(dispatch_queue_t)queue
                 always:(FSLPromiseAlwaysWorkBlock)work NS_REFINED_FOR_SWIFT;

@end

/**
 Convenience dot-syntax wrappers for `FSLPromise` `always` operators.
 Usage: promise.always(^{...})
 */
@interface FSLPromise<Value>(DotSyntax_AlwaysAdditions)

- (FSLPromise* (^)(FSLPromiseAlwaysWorkBlock))always FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");
- (FSLPromise* (^)(dispatch_queue_t, FSLPromiseAlwaysWorkBlock))alwaysOn FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
