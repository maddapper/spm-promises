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

@interface FSLPromise<Value>(RaceAdditions)

/**
 Wait until any of the given promises are fulfilled.
 If one of the promises is rejected, then the returned promise is rejected with same error.
 If any other arbitrary value or `NSError` appears in the array instead of `FSLPromise`,
 it's implicitly considered a pre-fulfilled or pre-rejected `FSLPromise` correspondingly.

 @param promises Promises to wait for.
 @return A new pending promise to be resolved with the same resolution as the first promise, among
         the given ones, which was resolved.
 */
+ (instancetype)race:(NSArray *)promises NS_SWIFT_UNAVAILABLE("");

/**
 Wait until any of the given promises are fulfilled.
 If one of the promises is rejected, then the returned promise is rejected with same error.
 If any other arbitrary value or `NSError` appears in the array instead of `FSLPromise`,
 it's implicitly considered a pre-fulfilled or pre-rejected `FSLPromise` correspondingly.

 @param queue A queue to dispatch on.
 @param promises Promises to wait for.
 @return A new pending promise to be resolved with the same resolution as the first promise, among
         the given ones, which was resolved.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue race:(NSArray *)promises NS_REFINED_FOR_SWIFT;

@end

/**
 Convenience dot-syntax wrappers for `FSLPromise` `race` operators.
 Usage: FSLPromise.race(@[ ... ])
 */
@interface FSLPromise<Value>(DotSyntax_RaceAdditions)

+ (FSLPromise * (^)(NSArray *))race FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise * (^)(dispatch_queue_t, NSArray *))raceOn FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
