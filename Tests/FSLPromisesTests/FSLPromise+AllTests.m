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

#import "FSLPromise+All.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Async.h"
#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseAllTests : XCTestCase
@end

@implementation FSLPromiseAllTests

- (void)testPromiseAll {
  // Arrange.
  NSArray *expectedValues = @[ @42, @"hello world", @[ @42 ], [NSNull null] ];
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
  FSLPromise<NSArray *> *combinedPromise =
      [[FSLPromise all:@[ promise1, promise2, promise3, promise4 ]] then:^id(NSArray *value) {
        XCTAssertEqualObjects(value, expectedValues);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(combinedPromise.value, expectedValues);
  XCTAssertNil(combinedPromise.error);
}

- (void)testPromiseAllEmpty {
  // Act.
  FSLPromise<NSArray *> *promise = [[FSLPromise all:@[]] then:^id(NSArray *value) {
    XCTAssertEqualObjects(value, @[]);
    return value;
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @[]);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAllRejectFirst {
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
  FSLPromise<NSArray *> *combinedPromise =
      [[[FSLPromise all:@[ promise1, promise2 ]] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(combinedPromise.error.code, 42);
  XCTAssertNil(combinedPromise.value);
}

- (void)testPromiseAllRejectLast {
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
  FSLPromise<NSArray *> *combinedPromise =
      [[[FSLPromise all:@[ promise1, promise2 ]] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(combinedPromise.error.code, 42);
  XCTAssertNil(combinedPromise.value);
}

- (void)testPromiseAllWithValues {
  // Arrange.
  NSArray *expectedValues = @[ @42, @"hello world", @[ @42 ], [NSNull null] ];
  FSLPromise<NSArray<NSNumber *> *> *promise1 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];
  FSLPromise *promise2 =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(1, ^{
          fulfill(nil);
        });
      }];

  // Act.
  FSLPromise<NSArray *> *combinedPromise =
      [[FSLPromise all:@[ @42, @"hello world", promise1, promise2 ]] then:^id(NSArray *value) {
        XCTAssertEqualObjects(value, expectedValues);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(combinedPromise.value, expectedValues);
  XCTAssertNil(combinedPromise.error);
}

- (void)testPromiseAllWithError {
  // Arrange.
  NSError *error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
  FSLPromise<NSArray<NSNumber *> *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@[ @42 ]);
        });
      }];

  // Act.
  FSLPromise<NSArray *> *combinedPromise =
      [[[FSLPromise all:@[ @42, error, promise ]] then:^id(id __unused _) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertEqual(error.code, 42);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(combinedPromise.error.code, 42);
  XCTAssertNil(combinedPromise.value);
}

/**
 Promise created with `all` should not deallocate until it gets resolved.
 */
- (void)testPromiseAllNoDeallocUntilResolved {
  // Arrange.
  FSLPromise *promise = [FSLPromise pendingPromise];
  FSLPromise __weak *weakExtendedPromise1;
  FSLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [FSLPromise all:@[ promise ]];
    weakExtendedPromise2 = [FSLPromise all:@[ promise ]];
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
