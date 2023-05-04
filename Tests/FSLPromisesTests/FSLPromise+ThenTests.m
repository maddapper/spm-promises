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

#import "FSLPromise+Then.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Async.h"
#import "FSLPromise+Do.h"
#import "FSLPromise+Testing.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseThenTests : XCTestCase
@end

@implementation FSLPromiseThenTests

- (void)testPromiseThen {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 4;
  NSUInteger const expectedArrayCount = 1;

  // Act.
  FSLPromise<NSNumber *> *numberPromise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        fulfill(@42);
      }];
  FSLPromise<NSString *> *stringPromise = [numberPromise then:^id(NSNumber *value) {
    ++count;
    return [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
      fulfill(value.stringValue);
    }];
  }];
  typedef NSArray<NSNumber *> * (^BlockPromise)(NSNumber *);
  FSLPromise<BlockPromise> *blockPromise = [stringPromise then:^id(NSString *value) {
    ++count;
    return [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
      fulfill(^(NSNumber *number) {
        return @[ @(number.integerValue + value.integerValue) ];
      });
    }];
  }];
  FSLPromise<BlockPromise> *finalPromise = [blockPromise then:^id(BlockPromise value) {
    ++count;
    return value;
  }];
  FSLPromise *postFinalPromise = [finalPromise then:^id(BlockPromise __unused _) {
    ++count;
    return nil;
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(numberPromise.value, @42);
  XCTAssertNil(numberPromise.error);
  XCTAssertEqualObjects(stringPromise.value, @"42");
  XCTAssertNil(stringPromise.error);
  XCTAssertNotNil(blockPromise.value);
  BlockPromise block = blockPromise.value;
  NSArray<NSNumber *> *array = block(@42);
  XCTAssertEqual(array.count, expectedArrayCount);
  XCTAssertEqualObjects(array.firstObject, @84);
  XCTAssertNil(blockPromise.error);
  XCTAssertEqualObjects(finalPromise.value, blockPromise.value);
  XCTAssertNil(finalPromise.error);
  XCTAssertTrue(postFinalPromise.isFulfilled);
  XCTAssertNil(postFinalPromise.value);
  XCTAssertNil(postFinalPromise.error);
}

- (void)testPromiseAsyncFulfill {
  // Act.
  FSLPromise<NSNumber *> *promise =
      [[FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
        });
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseChainedFulfill {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FSLPromise<NSNumber *> *promise = [[[[FSLPromise do:^id {
    return @42;
  }] then:^id(NSNumber *value) {
    XCTAssertEqualObjects(value, @42);
    ++count;
    return value;
  }] then:^id(NSNumber *value) {
    XCTAssertEqualObjects(value, @42);
    ++count;
    return value;
  }] then:^id(NSNumber *value) {
    XCTAssertEqualObjects(value, @42);
    ++count;
    return value;
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseChainedAsyncFulfill {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 3;

  // Act.
  FSLPromise<NSNumber *> *promise =
      [[[[FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
        });
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        ++count;
        return value;
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        ++count;
        return value;
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        ++count;
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseNoThenOnPending {
  // Arrange.
  XCTestExpectation *expectation = [self expectationWithDescription:@""];

  // Act.
  FSLPromise *promise = [FSLPromise pendingPromise];
  FSLPromise *thenPromise = [promise then:^id(id __unused _) {
    XCTFail();
    return nil;
  }];
  FSLDelay(0.1, ^{
    [expectation fulfill];
  });

  // Assert.
  [self waitForExpectationsWithTimeout:10 handler:nil];
  XCTAssertTrue(promise.isPending);
  XCTAssertNil(promise.value);
  XCTAssertNil(promise.error);
  XCTAssertTrue(thenPromise.isPending);
  XCTAssertNil(thenPromise.value);
  XCTAssertNil(thenPromise.error);
}

- (void)testPromiseNoDoubleFulfill {
  // Act.
  FSLPromise<NSNumber *> *promise =
      [[FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
          fulfill(@13);
        });
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseThenReturnValue {
  // Arrange.
  NSUInteger __block count = 0;
  NSUInteger const expectedCount = 4;
  NSUInteger const expectedArrayCount = 1;

  // Act.
  FSLPromise<NSNumber *> *numberPromise = [FSLPromise do:^id {
    return @42;
  }];
  FSLPromise<NSString *> *stringPromise = [numberPromise then:^id(NSNumber *value) {
    ++count;
    return value.stringValue;
  }];
  typedef NSArray<NSNumber *> * (^BlockPromise)(NSNumber *);
  FSLPromise<BlockPromise> *blockPromise = [stringPromise then:^id(NSString *value) {
    ++count;
    return ^(NSNumber *number) {
      return @[ @(number.integerValue + value.integerValue) ];
    };
  }];
  FSLPromise<BlockPromise> *finalPromise = [blockPromise then:^id(BlockPromise value) {
    ++count;
    return value;
  }];
  FSLPromise *postFinalPromise = [finalPromise then:^id(BlockPromise __unused _) {
    ++count;
    return nil;
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
  XCTAssertEqualObjects(numberPromise.value, @42);
  XCTAssertNil(numberPromise.error);
  XCTAssertEqualObjects(stringPromise.value, @"42");
  XCTAssertNil(stringPromise.error);
  XCTAssertNotNil(blockPromise.value);
  BlockPromise block = blockPromise.value;
  NSArray<NSNumber *> *array = block(@42);
  XCTAssertEqual(array.count, expectedArrayCount);
  XCTAssertEqualObjects(array.firstObject, @84);
  XCTAssertNil(blockPromise.error);
  XCTAssertEqualObjects(finalPromise.value, blockPromise.value);
  XCTAssertNil(finalPromise.error);
  XCTAssertTrue(postFinalPromise.isFulfilled);
  XCTAssertNil(postFinalPromise.value);
  XCTAssertNil(postFinalPromise.error);
}

- (void)testPromiseThenInitiallyFulfilled {
  // Act.
  FSLPromise<NSNumber *> *initiallyFulfilledPromise = [FSLPromise resolvedWith:@42];
  FSLPromise<NSNumber *> *promise = [initiallyFulfilledPromise then:^id(NSNumber *value) {
    XCTAssertEqualObjects(value, @42);
    return value;
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(initiallyFulfilledPromise.value, @42);
  XCTAssertNil(initiallyFulfilledPromise.error);
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

/**
 Promise created with `then` should not deallocate until it gets resolved.
 */
- (void)testPromiseThenNoDeallocUntilFulfilled {
  // Arrange.
  FSLPromise *promise = [FSLPromise pendingPromise];
  FSLPromise __weak *weakExtendedPromise1;
  FSLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [promise then:^id(id __unused _) {
      return nil;
    }];
    weakExtendedPromise2 = [promise then:^id(id __unused _) {
      return nil;
    }];
    XCTAssertNotNil(weakExtendedPromise1);
    XCTAssertNotNil(weakExtendedPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakExtendedPromise1);
  XCTAssertNotNil(weakExtendedPromise2);

  [promise fulfill:@42];
  XCTAssert(FSLWaitForPromisesWithTimeout(10));

  XCTAssertNil(weakExtendedPromise1);
  XCTAssertNil(weakExtendedPromise2);
}

@end
