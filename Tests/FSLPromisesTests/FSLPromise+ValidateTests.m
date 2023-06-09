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

#import "FSLPromise+Validate.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Async.h"
#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseValidateTests : XCTestCase
@end

@implementation FSLPromiseValidateTests

- (void)testPromiseValidateTrue {
  // Act.
  FSLPromise<NSNumber *> *promise =
      [[[[FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
        });
      }] validate:^BOOL(NSNumber *value) {
        return value.integerValue == 42;
      }] catch:^(NSError __unused *_) {
        XCTFail();
      }] then:^id(NSNumber *value) {
        XCTAssertEqualObjects(value, @42);
        return value;
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @42);
  XCTAssertNil(promise.error);
}

- (void)testPromiseValidateFalse {
  // Act.
  FSLPromise<NSNumber *> *promise =
      [[[[FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
        FSLDelay(0.1, ^{
          fulfill(@42);
        });
      }] validate:^BOOL(NSNumber *value) {
        return value.integerValue != 42;
      }] then:^id(NSNumber __unused *_) {
        XCTFail();
        return nil;
      }] catch:^(NSError *error) {
        XCTAssertTrue(FSLPromiseErrorIsValidationFailure(error));
      }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertTrue(FSLPromiseErrorIsValidationFailure(promise.error));
  XCTAssertNil(promise.value);
}

/**
 Promise created with `validate` should not deallocate until it gets resolved.
 */
- (void)testPromiseValidateNoDeallocUntilResolved {
  // Arrange.
  FSLPromise *promise = [FSLPromise pendingPromise];
  FSLPromise __weak *weakExtendedPromise1;
  FSLPromise __weak *weakExtendedPromise2;

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [promise validate:^BOOL(id __unused _) {
      return YES;
    }];
    weakExtendedPromise2 = [promise validate:^BOOL(id __unused _) {
      return YES;
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
