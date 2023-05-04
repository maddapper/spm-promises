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
#import "FSLPromise+Testing.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseAsyncTests : XCTestCase
@end

@implementation FSLPromiseAsyncTests

- (void)testPromiseAsyncFulfill {
  // Arrange & Act.
  FSLPromise<NSNumber *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        fulfill(@42);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAsyncFulfillWithPromise {
  // Arrange & Act.
  FSLPromise<NSNumber *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        fulfill([FSLPromise resolvedWith:@42]);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAsyncReject {
  // Arrange & Act.
  FSLPromise<NSNumber *> *promise =
      [FSLPromise async:^(FSLPromiseFulfillBlock __unused _, FSLPromiseRejectBlock reject) {
        reject([NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil]);
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.error.domain, FSLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
  XCTAssertNil(promise.value);
}

/**
 Promise created with `async` should not deallocate until it gets resolved.
 */
- (void)testPromiseAsyncNoDeallocUntilFulfilled {
  // Arrange.
  FSLPromise __weak *weakPromise1;
  FSLPromise __weak *weakPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakPromise1);
    XCTAssertNil(weakPromise2);
    weakPromise1 =
        [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
          fulfill(@42);
        }];
    weakPromise2 =
        [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
          fulfill(@42);
        }];
    XCTAssertNotNil(weakPromise1);
    XCTAssertNotNil(weakPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakPromise1);
  XCTAssertNotNil(weakPromise2);
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertNil(weakPromise1);
  XCTAssertNil(weakPromise2);
}

@end
