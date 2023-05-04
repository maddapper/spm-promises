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

/**
 Different types of completion handlers available to be wrapped with promise.
 */
typedef void (^FSLPromiseCompletion)(void) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseObjectCompletion)(id __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseErrorCompletion)(NSError* __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseObjectOrErrorCompletion)(id __nullable, NSError* __nullable)
    NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseErrorOrObjectCompletion)(NSError* __nullable, id __nullable)
    NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromise2ObjectsOrErrorCompletion)(id __nullable, id __nullable,
                                                    NSError* __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseBoolCompletion)(BOOL) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseBoolOrErrorCompletion)(BOOL, NSError* __nullable) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseIntegerCompletion)(NSInteger) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseIntegerOrErrorCompletion)(NSInteger, NSError* __nullable)
    NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseDoubleCompletion)(double) NS_SWIFT_UNAVAILABLE("");
typedef void (^FSLPromiseDoubleOrErrorCompletion)(double, NSError* __nullable)
    NS_SWIFT_UNAVAILABLE("");

/**
 Provides an easy way to convert methods that use common callback patterns into promises.
 */
@interface FSLPromise<Value>(WrapAdditions)

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with `nil` when completion handler is invoked.
 */
+ (instancetype)wrapCompletion:(void (^)(FSLPromiseCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with `nil` when completion handler is invoked.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue
         wrapCompletion:(void (^)(FSLPromiseCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an object provided by completion handler.
 */
+ (instancetype)wrapObjectCompletion:(void (^)(FSLPromiseObjectCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an object provided by completion handler.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapObjectCompletion:(void (^)(FSLPromiseObjectCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an error provided by completion handler.
 If error is `nil`, fulfills with `nil`, otherwise rejects with the error.
 */
+ (instancetype)wrapErrorCompletion:(void (^)(FSLPromiseErrorCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an error provided by completion handler.
 If error is `nil`, fulfills with `nil`, otherwise rejects with the error.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapErrorCompletion:(void (^)(FSLPromiseErrorCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an object provided by completion handler if error is `nil`.
 Otherwise, rejects with the error.
 */
+ (instancetype)wrapObjectOrErrorCompletion:
    (void (^)(FSLPromiseObjectOrErrorCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an object provided by completion handler if error is `nil`.
 Otherwise, rejects with the error.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapObjectOrErrorCompletion:(void (^)(FSLPromiseObjectOrErrorCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an error or object provided by completion handler. If error
 is not `nil`, rejects with the error.
 */
+ (instancetype)wrapErrorOrObjectCompletion:
    (void (^)(FSLPromiseErrorOrObjectCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an error or object provided by completion handler. If error
 is not `nil`, rejects with the error.
 */
+ (instancetype)onQueue:(dispatch_queue_t)queue
    wrapErrorOrObjectCompletion:(void (^)(FSLPromiseErrorOrObjectCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an array of objects provided by completion handler in order
 if error is `nil`. Otherwise, rejects with the error.
 */
+ (FSLPromise<NSArray*>*)wrap2ObjectsOrErrorCompletion:
    (void (^)(FSLPromise2ObjectsOrErrorCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an array of objects provided by completion handler in order
 if error is `nil`. Otherwise, rejects with the error.
 */
+ (FSLPromise<NSArray*>*)onQueue:(dispatch_queue_t)queue
    wrap2ObjectsOrErrorCompletion:(void (^)(FSLPromise2ObjectsOrErrorCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping YES/NO.
 */
+ (FSLPromise<NSNumber*>*)wrapBoolCompletion:(void (^)(FSLPromiseBoolCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping YES/NO.
 */
+ (FSLPromise<NSNumber*>*)onQueue:(dispatch_queue_t)queue
               wrapBoolCompletion:(void (^)(FSLPromiseBoolCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping YES/NO when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FSLPromise<NSNumber*>*)wrapBoolOrErrorCompletion:
    (void (^)(FSLPromiseBoolOrErrorCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping YES/NO when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FSLPromise<NSNumber*>*)onQueue:(dispatch_queue_t)queue
        wrapBoolOrErrorCompletion:(void (^)(FSLPromiseBoolOrErrorCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping an integer.
 */
+ (FSLPromise<NSNumber*>*)wrapIntegerCompletion:(void (^)(FSLPromiseIntegerCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping an integer.
 */
+ (FSLPromise<NSNumber*>*)onQueue:(dispatch_queue_t)queue
            wrapIntegerCompletion:(void (^)(FSLPromiseIntegerCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping an integer when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FSLPromise<NSNumber*>*)wrapIntegerOrErrorCompletion:
    (void (^)(FSLPromiseIntegerOrErrorCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping an integer when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FSLPromise<NSNumber*>*)onQueue:(dispatch_queue_t)queue
     wrapIntegerOrErrorCompletion:(void (^)(FSLPromiseIntegerOrErrorCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping a double.
 */
+ (FSLPromise<NSNumber*>*)wrapDoubleCompletion:(void (^)(FSLPromiseDoubleCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping a double.
 */
+ (FSLPromise<NSNumber*>*)onQueue:(dispatch_queue_t)queue
             wrapDoubleCompletion:(void (^)(FSLPromiseDoubleCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

/**
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping a double when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FSLPromise<NSNumber*>*)wrapDoubleOrErrorCompletion:
    (void (^)(FSLPromiseDoubleOrErrorCompletion handler))work NS_SWIFT_UNAVAILABLE("");

/**
 @param queue A queue to invoke the `work` block on.
 @param work A block to perform any operations needed to resolve the promise.
 @returns A promise that resolves with an `NSNumber` wrapping a double when error is `nil`.
 Otherwise rejects with the error.
 */
+ (FSLPromise<NSNumber*>*)onQueue:(dispatch_queue_t)queue
      wrapDoubleOrErrorCompletion:(void (^)(FSLPromiseDoubleOrErrorCompletion handler))work
    NS_SWIFT_UNAVAILABLE("");

@end

/**
 Convenience dot-syntax wrappers for `FSLPromise` `wrap` operators.
 Usage: FSLPromise.wrapCompletion(^(FSLPromiseCompletion handler) {...})
 */
@interface FSLPromise<Value>(DotSyntax_WrapAdditions)

+ (FSLPromise* (^)(void (^)(FSLPromiseCompletion)))wrapCompletion FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(dispatch_queue_t, void (^)(FSLPromiseCompletion)))wrapCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(void (^)(FSLPromiseObjectCompletion)))wrapObjectCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(dispatch_queue_t, void (^)(FSLPromiseObjectCompletion)))wrapObjectCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(void (^)(FSLPromiseErrorCompletion)))wrapErrorCompletion FSL_PROMISES_DOT_SYNTAX
    NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(dispatch_queue_t, void (^)(FSLPromiseErrorCompletion)))wrapErrorCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(void (^)(FSLPromiseObjectOrErrorCompletion)))wrapObjectOrErrorCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(dispatch_queue_t,
                   void (^)(FSLPromiseObjectOrErrorCompletion)))wrapObjectOrErrorCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(void (^)(FSLPromiseErrorOrObjectCompletion)))wrapErrorOrObjectCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise* (^)(dispatch_queue_t,
                   void (^)(FSLPromiseErrorOrObjectCompletion)))wrapErrorOrObjectCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSArray*>* (^)(void (^)(FSLPromise2ObjectsOrErrorCompletion)))
    wrap2ObjectsOrErrorCompletion FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSArray*>* (^)(dispatch_queue_t, void (^)(FSLPromise2ObjectsOrErrorCompletion)))
    wrap2ObjectsOrErrorCompletionOn FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(void (^)(FSLPromiseBoolCompletion)))wrapBoolCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(dispatch_queue_t,
                              void (^)(FSLPromiseBoolCompletion)))wrapBoolCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(void (^)(FSLPromiseBoolOrErrorCompletion)))wrapBoolOrErrorCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(dispatch_queue_t,
                              void (^)(FSLPromiseBoolOrErrorCompletion)))wrapBoolOrErrorCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(void (^)(FSLPromiseIntegerCompletion)))wrapIntegerCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(dispatch_queue_t,
                              void (^)(FSLPromiseIntegerCompletion)))wrapIntegerCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(void (^)(FSLPromiseIntegerOrErrorCompletion)))
    wrapIntegerOrErrorCompletion FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(dispatch_queue_t, void (^)(FSLPromiseIntegerOrErrorCompletion)))
    wrapIntegerOrErrorCompletionOn FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(void (^)(FSLPromiseDoubleCompletion)))wrapDoubleCompletion
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(dispatch_queue_t,
                              void (^)(FSLPromiseDoubleCompletion)))wrapDoubleCompletionOn
    FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(void (^)(FSLPromiseDoubleOrErrorCompletion)))
    wrapDoubleOrErrorCompletion FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");
+ (FSLPromise<NSNumber*>* (^)(dispatch_queue_t, void (^)(FSLPromiseDoubleOrErrorCompletion)))
    wrapDoubleOrErrorCompletionOn FSL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
