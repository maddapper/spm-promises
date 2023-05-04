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

#import "FSLPromise+Race.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Async.h"
#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseRaceTests : XCTestCase
@end

@implementation FSLPromiseRaceTests

- (void)testPromiseRace {
  // Arrange.
  FSLPromise<NSNumber *> *promise1 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
        });
      }];
  FSLPromise<NSString *> *promise2 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(1, ^{
          fulfill(@"hello world");
        });
      }];
  FSLPromise<NSArray<NSNumber *> *> *promise3 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(2, ^{
          fulfill(@[ @42 ]);
        });
      }];
  FSLPromise *promise4 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(3, ^{
          fulfill(nil);
        });
      }];

  // Act.
  FSLPromise *fastestPromise =
      [[FSLPromise race:@[ promise1, promise2, promise3, promise4 ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

- (void)testPromiseRaceRejectFirst {
  // Arrange.
  FSLPromise<NSNumber *> *promise1 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(1, ^{
          fulfill(@42);
        });
      }];
  FSLPromise<NSString *> *promise2 =
      [FSLPromise async:^(FSLPromiseFulfillBlock __unused _, FSLPromiseRejectBlock reject) {
        FSLDelay(0.1, ^{
          reject([NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }];

  // Act.
  FSLPromise *fastestPromise = [[[FSLPromise race:@[ promise1, promise2 ]] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(fastestPromise.error.code, 42);
  XCTAssertNil(fastestPromise.value);
}

- (void)testPromiseRaceRejectLast {
  // Arrange.
  FSLPromise<NSNumber *> *promise1 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
        });
      }];
  FSLPromise<NSString *> *promise2 =
      [FSLPromise async:^(FSLPromiseFulfillBlock __unused _, FSLPromiseRejectBlock reject) {
        FSLDelay(1, ^{
          reject([NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil]);
        });
      }];

  // Act.
  FSLPromise *fastestPromise =
      [[FSLPromise race:@[ promise1, promise2 ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

- (void)testPromiseRaceWithValues {
  // Arrange.
  FSLPromise<NSArray<NSNumber *> *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FSLPromise *fastestPromise =
      [[FSLPromise race:@[ @42, @"hello world", promise ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

- (void)testPromiseRaceWithErrorFirst {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
  FSLPromise<NSArray<NSNumber *> *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FSLPromise *fastestPromise =
      [[[FSLPromise race:@[ promise, error, @42 ]] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(fastestPromise.error.code, 42);
  XCTAssertNil(fastestPromise.value);
}

- (void)testPromiseRaceWithErrorLast {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
  FSLPromise<NSArray<NSNumber *> *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FSLPromise *fastestPromise =
      [[FSLPromise race:@[ promise, @42, error ]] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(fastestPromise.value, @42);
  XCTAssertNil(fastestPromise.error);
}

/**
 Promise created with `race` should not deallocate until it gets resolved.
 */
- (void)testPromiseRaceNoDeallocUntilResolved {
  // Arrange.
  FSLPromise *promise = [FSLPromise pendingPromise];
  FSLPromise __weak *weakExtendedPromise1;
  FSLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [FSLPromise race:@[ promise ]];
    weakExtendedPromise2 = [FSLPromise race:@[ promise ]];
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
