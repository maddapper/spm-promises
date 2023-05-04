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

#import <XCTest/XCTest.h>

#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseWrapTests : XCTestCase
@end

@implementation FSLPromiseWrapTests

- (void)testPromiseWrapVoidCompletionFulfillsWithNilValue {
  // Act.
  FSLPromise *promise = [FSLPromise wrapCompletion:^(FSLPromiseCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithCompletion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapObjectCompletion:^(FSLPromiseObjectCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectCompletionFulfillsWithNilValue {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapObjectCompletion:^(FSLPromiseObjectCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapErrorCompletion:^(FSLPromiseErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithError:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapErrorCompletionFulfillsWithNilValue {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapErrorCompletion:^(FSLPromiseErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithError:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(promise.isFulfilled);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapObjectOrErrorCompletion:^(FSLPromiseObjectOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapErrorOrObjectCompletionFulfillsOnValueReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapErrorOrObjectCompletion:^(FSLPromiseErrorOrObjectCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithError:nil object:@42 completion:handler];
      [expectation fulfill];
    });
  }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapObjectOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapObjectOrErrorCompletion:^(FSLPromiseObjectOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:nil error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapErrorOrObjectCompletionRejectsOnErrorReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapErrorOrObjectCompletion:^(FSLPromiseErrorOrObjectCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithError:error object:nil completion:handler];
      [expectation fulfill];
    });
  }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapObjectOrErrorCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapObjectOrErrorCompletion:^(FSLPromiseObjectOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapErrorOrObjectCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapErrorOrObjectCompletion:^(FSLPromiseErrorOrObjectCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithError:error object:@42 completion:handler];
      [expectation fulfill];
    });
  }];

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrap2ObjectsOrErrorCompletionFulfillsOnValueReturned {
  // Arrange.
  NSArray *expectedValues = @[ @42, [NSNull null] ];

  // Act.
  FSLPromise<NSArray *> *promise =
  [FSLPromise wrap2ObjectsOrErrorCompletion:^(FSLPromise2ObjectsOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 object:nil error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, expectedValues);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrap2ObjectsOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSArray *> *promise =
  [FSLPromise wrap2ObjectsOrErrorCompletion:^(FSLPromise2ObjectsOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:nil object:nil error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrap2ObjectsOrErrorCompletionRejectsOnValueAndErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSArray *> *promise =
  [FSLPromise wrap2ObjectsOrErrorCompletion:^(FSLPromise2ObjectsOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithObject:@42 object:@13 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapBoolOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapBoolOrErrorCompletion:^(FSLPromiseBoolOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithBool:YES error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @YES);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapBoolOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapBoolOrErrorCompletion:^(FSLPromiseBoolOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithBool:YES error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapBoolCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapBoolCompletion:^(FSLPromiseBoolCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithBool:YES completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @YES);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapIntegerOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapIntegerOrErrorCompletion:^(FSLPromiseIntegerOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithInteger:42 error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapIntegerOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapIntegerOrErrorCompletion:^(FSLPromiseIntegerOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithInteger:42 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapIntegerCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapIntegerCompletion:^(FSLPromiseIntegerCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithInteger:42 completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapDoubleOrErrorCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapDoubleOrErrorCompletion:^(FSLPromiseDoubleOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithDouble:42.0 error:nil completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42.0);
  XCTAssertNil(promise.error);
}

- (void)testPromiseWrapDoubleOrErrorCompletionRejectsOnErrorReturned {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapDoubleOrErrorCompletion:^(FSLPromiseDoubleOrErrorCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithDouble:42.0 error:error completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error, error);
  XCTAssertNil(promise.value);
}

- (void)testPromiseWrapDoubleCompletionFulfillsOnValueReturned {
  // Act.
  FSLPromise<NSNumber *> *promise =
  [FSLPromise wrapDoubleCompletion:^(FSLPromiseDoubleCompletion handler) {
    FSLDelay(0.1, ^{
      [self wrapHarnessWithDouble:42.0 completion:handler];
    });
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42.0);
  XCTAssertNil(promise.error);
}

#pragma mark - Private

- (void)wrapHarnessWithCompletion:(FSLPromiseCompletion)handler {
  handler();
}

- (void)wrapHarnessWithObject:(id __nullable)value completion:(FSLPromiseObjectCompletion)handler {
  handler(value);
}

- (void)wrapHarnessWithError:(NSError *__nullable)error
                  completion:(FSLPromiseErrorCompletion)handler {
  handler(error);
}

- (void)wrapHarnessWithObject:(id __nullable)value
                        error:(NSError *__nullable)error
                   completion:(FSLPromiseObjectOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithError:(NSError *__nullable)error
                      object:(id __nullable)value
                  completion:(FSLPromiseErrorOrObjectCompletion)handler {
  handler(error, value);
}

- (void)wrapHarnessWithObject:(id __nullable)value1
                       object:(id __nullable)value2
                        error:(NSError *__nullable)error
                   completion:(FSLPromise2ObjectsOrErrorCompletion)handler {
  handler(value1, value2, error);
}

- (void)wrapHarnessWithBool:(BOOL)value
                      error:(NSError *__nullable)error
                 completion:(FSLPromiseBoolOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithBool:(BOOL)value completion:(FSLPromiseBoolCompletion)handler {
  handler(value);
}

- (void)wrapHarnessWithInteger:(NSInteger)value
                         error:(NSError *__nullable)error
                    completion:(FSLPromiseIntegerOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithInteger:(NSInteger)value completion:(FSLPromiseIntegerCompletion)handler {
  handler(value);
}

- (void)wrapHarnessWithDouble:(double)value
                        error:(NSError *__nullable)error
                   completion:(FSLPromiseDoubleOrErrorCompletion)handler {
  handler(value, error);
}

- (void)wrapHarnessWithDouble:(double)value completion:(FSLPromiseDoubleCompletion)handler {
  handler(value);
}

@end
