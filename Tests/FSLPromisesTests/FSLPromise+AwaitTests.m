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

#import "FSLPromise+Await.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Async.h"
#import "FSLPromise+Do.h"
#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseAwaitTests : XCTestCase
@end

@implementation FSLPromiseAwaitTests

- (void)testPromiseAwaitFulfill {
  // Arrange & Act.
  FSLPromise<NSNumber *> *promise = [FSLPromise
      onQueue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT)
           do:^id {
             NSError *error;
             NSNumber *minusFive = FSLPromiseAwait([self awaitHarnessNegate:@5], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(minusFive, @-5);
             NSNumber *twentyFive =
                 FSLPromiseAwait([self awaitHarnessMultiply:minusFive by:minusFive], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(twentyFive, @25);
             NSNumber *twenty =
                 FSLPromiseAwait([self awaitHarnessAdd:twentyFive to:minusFive], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(twenty, @20);
             NSNumber *five =
                 FSLPromiseAwait([self awaitHarnessSubtract:twentyFive from:twenty], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(five, @5);
             NSNumber *zero = FSLPromiseAwait([self awaitHarnessAdd:minusFive to:five], &error);
             if (error) {
               return error;
             }
             XCTAssertEqualObjects(zero, @0);
             NSNumber *result = FSLPromiseAwait([self awaitHarnessMultiply:zero by:five], &error);
             if (error) {
               return error;
             }
             return result;
           }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqualObjects(promise.value, @0);
  XCTAssertNil(promise.error);
}

- (void)testPromiseAwaitReject {
  // Arrange
  NSError *expectedError = [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];

  // Act.
  FSLPromise<NSNumber *> *promise =
      [FSLPromise onQueue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT)
                       do:^id {
                         NSError *error;
                         id value = FSLPromiseAwait([self awaitHarnessFail:expectedError], &error);
                         XCTAssertNil(value);
                         XCTAssertEqualObjects(error.domain, FSLPromiseErrorDomain);
                         XCTAssertEqual(error.code, 42);
                         return value ?: error;
                       }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertNil(promise.value);
  XCTAssertEqualObjects(promise.error.domain, FSLPromiseErrorDomain);
  XCTAssertEqual(promise.error.code, 42);
}

#pragma mark - Private

- (FSLPromise<NSNumber *> *)awaitHarnessNegate:(NSNumber *)number {
  return [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
    FSLDelay(0.1, ^{
      fulfill(@(-number.integerValue));
    });
  }];
}

- (FSLPromise<NSNumber *> *)awaitHarnessAdd:(NSNumber *)number to:(NSNumber *)number2 {
  return [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
    FSLDelay(0.1, ^{
      fulfill(@(number.integerValue + number2.integerValue));
    });
  }];
}

- (FSLPromise<NSNumber *> *)awaitHarnessSubtract:(NSNumber *)number from:(NSNumber *)number2 {
  return [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
    FSLDelay(0.1, ^{
      fulfill(@(number.integerValue - number2.integerValue));
    });
  }];
}

- (FSLPromise<NSNumber *> *)awaitHarnessMultiply:(NSNumber *)number by:(NSNumber *)number2 {
  return [FSLPromise async:^(FSLPromiseFulfillBlock fulfill, FSLPromiseRejectBlock __unused _) {
    FSLDelay(0.1, ^{
      fulfill(@(number.integerValue * number2.integerValue));
    });
  }];
}

- (FSLPromise<NSNumber *> *)awaitHarnessFail:(NSError *)error {
  return [FSLPromise async:^(FSLPromiseFulfillBlock __unused _, FSLPromiseRejectBlock reject) {
    FSLDelay(0.1, ^{
      reject(error);
    });
  }];
}

@end
