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

#import "FSLPromise+Retry.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Async.h"
#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseRetryTests : XCTestCase
@end

@implementation FSLPromiseRetryTests

- (void)testPromiseRetryWithDefaultRetryAttemptAfterInitialReject {
  // Arrange.
  // Initial attempt count plus retry attempts count.
  NSUInteger __block count = 1 + FSLPromiseRetryDefaultAttemptsCount;
  NSUInteger const expectedCount = 0;

  // Act.
  [[[FSLPromise retry:^id {
    count -= 1;
    return count == 0 ? @42 : [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
  }] then:^id(NSNumber *value) {
    XCTAssertEqual(value, @42);
    return nil;
  }] catch:^(NSError __unused *_) {
    XCTFail(@"Promise should not be resolved with error.");
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(count, expectedCount);
}

- (void)testPromiseRetryNoRetryAttemptOnInitialFulfill {
  // Arrange.
  NSUInteger __block count = 1 + FSLPromiseRetryDefaultAttemptsCount;
  NSUInteger const expectedCount = FSLPromiseRetryDefaultAttemptsCount;

  // Act.
  [[[FSLPromise retry:^id {
    count -= 1;
    return @42;
  }] then:^id(NSNumber *value) {
    XCTAssertEqual(value, @42);
    return nil;
  }] catch:^(NSError __unused *_) {
    XCTFail(@"Promise should not be resolved with error.");
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(count, expectedCount);
}

- (void)testPromiseRetryExhaustsAllRetryAttemptsBeforeRejection {
  // Arrange.
  NSUInteger customAttempts = 3;
  NSUInteger __block count = 1 + customAttempts;
  NSUInteger const expectedCount = 0;
  NSError *retryError = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  [[[FSLPromise attempts:customAttempts
                   retry:^id {
                     count -= 1;
                     return retryError;
                   }] then:^id(NSNumber __unused *_) {
    XCTFail(@"Promise should not be resolved with value.");
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error, retryError);
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(count, expectedCount);
}

- (void)testPromiseRetryAttemptMadeAfterDefaultDelay {
  // Arrange.
  NSUInteger customAttempts = 3;
  NSUInteger __block count = 1 + customAttempts;
  NSUInteger const expectedCount = 0;
  NSDate __block *startDate = [NSDate date];

  // Act.
  [[[FSLPromise
      attempts:customAttempts
         retry:^id {
           if (count <= customAttempts) {
             NSTimeInterval timeInterval = round([[NSDate date] timeIntervalSinceDate:startDate]);
             XCTAssertGreaterThanOrEqual(timeInterval, FSLPromiseRetryDefaultDelayInterval);
           }
           count -= 1;
           startDate = [NSDate date];
           return count == 0 ? @42
                             : [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
         }] then:^id(NSNumber *value) {
    XCTAssertEqual(value, @42);
    return nil;
  }] catch:^(NSError __unused *_) {
    XCTFail(@"Promise should not be resolved with error.");
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(count, expectedCount);
}

- (void)testPromiseRetryAttemptMadeAfterCustomDelay {
  // Arrange.
  NSTimeInterval customDelay = 2.0;
  NSUInteger customAttempts = 2;
  NSUInteger __block count = 1 + customAttempts;
  NSUInteger const expectedCount = 0;
  NSDate __block *startDate = [NSDate date];

  // Act.
  [[[FSLPromise
       attempts:customAttempts
          delay:customDelay
      condition:nil
          retry:^id {
            if (count <= customAttempts) {
              NSTimeInterval timeInterval = round([[NSDate date] timeIntervalSinceDate:startDate]);
              XCTAssertGreaterThanOrEqual(timeInterval, customDelay);
            }
            count -= 1;
            startDate = [NSDate date];
            return count == 0
                       ? @42
                       : [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
          }] then:^id(NSNumber *value) {
    XCTAssertEqual(value, @42);
    return nil;
  }] catch:^(NSError __unused *_) {
    XCTFail(@"Promise should not be resolved with error.");
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(count, expectedCount);
}

- (void)testPromiseRetryRejectsBeforeRetryAttemptsAreExhaustedIfPredicateIsNotMet {
  // Arrange.
  NSInteger customAttempts = 3;
  NSInteger __block attemptsCount = 1 + customAttempts;
  NSInteger const expectedCount = 1;
  NSError *retry42Error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
  NSError *retry13Error = [NSError errorWithDomain:FSLPromiseErrorDomain code:13 userInfo:nil];

  // Act.
  [[[FSLPromise attempts:customAttempts
      delay:FSLPromiseRetryDefaultDelayInterval
      condition:^BOOL(NSInteger remainingAttempts, NSError *error) {
        XCTAssertEqual(attemptsCount, remainingAttempts);
        return error.code == retry42Error.code;
      }
      retry:^id {
        attemptsCount -= 1;
        return attemptsCount > 1 ? retry42Error : retry13Error;
      }] then:^id(NSNumber __unused *_) {
    XCTFail(@"Promise should not be resolved with value.");
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error, retry13Error);
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(attemptsCount, expectedCount);
}

- (void)testPromiseRetryNoDeallocUntilResolved {
  // Arrange.
  FSLPromise *promise = [FSLPromise pendingPromise];
  FSLPromise __weak *weakExtendedPromise1;
  FSLPromise __weak *weakExtendedPromise2;
  NSInteger customAttempts = 3;
  NSInteger __block attemptsCount = 1 + customAttempts;
  NSInteger const expectedCount = 1;
  NSError *retry42Error = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  @autoreleasepool {
    XCTAssertNil(weakExtendedPromise1);
    XCTAssertNil(weakExtendedPromise2);
    weakExtendedPromise1 = [FSLPromise retry:^id {
      return promise;
    }];
    weakExtendedPromise2 = [FSLPromise attempts:customAttempts
        delay:FSLPromiseRetryDefaultDelayInterval
        condition:^BOOL(NSInteger remainingAttempts, NSError *error) {
          XCTAssertEqual(attemptsCount, remainingAttempts);
          return error.code == retry42Error.code;
        }
        retry:^id {
          attemptsCount -= 1;
          return attemptsCount > 1 ? retry42Error : promise;
        }];
    XCTAssertNotNil(weakExtendedPromise1);
    XCTAssertNotNil(weakExtendedPromise2);
  }

  // Assert.
  XCTAssertNotNil(weakExtendedPromise1);
  XCTAssertNotNil(weakExtendedPromise2);

  [promise fulfill:@42];
  XCTAssert(FSLWaitForPromisesWithTimeout(15.0));
  XCTAssertEqual(attemptsCount, expectedCount);
  XCTAssertNil(weakExtendedPromise1);
  XCTAssertNil(weakExtendedPromise2);
}

@end
