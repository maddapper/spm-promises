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

#import "FSLPromise+Reduce.h"

#import <XCTest/XCTest.h>

#import "FSLPromise+Catch.h"
#import "FSLPromise+Testing.h"
#import "FSLPromise+Then.h"
#import "FSLPromisesTestHelpers.h"

@interface FSLPromiseReduceTests : XCTestCase
@end

@implementation FSLPromiseReduceTests

- (void)testPromiseReduce {
  // Arrange.
  NSArray<NSNumber *> *numbers = @[ @1, @2, @3 ];
  NSUInteger __block count = 0;

  // Act.
  [[[[FSLPromise resolvedWith:@""] reduce:numbers
                                  combine:^id(NSString *partialString, NSNumber *nextNumber) {
    ++count;
    return [partialString stringByAppendingString:nextNumber.stringValue];
  }] then:^id(NSString *string) {
    XCTAssertEqualObjects(string, @"123");
    ++count;
    return nil;
  }] catch:^(NSError __unused *_) {
    XCTFail();
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, numbers.count + 1);
}

- (void)testPromiseReduceReject {
  // Arrange.
  NSArray<NSNumber *> *numbers = @[ @1, @2, @3 ];
  NSUInteger const expectedCount = 2;
  NSUInteger __block count = 0;

  // Act.
  [[[[FSLPromise resolvedWith:@""]
       reduce:numbers
      combine:^id(NSString *partialString, NSNumber *nextNumber) {
    if (partialString.length > 0) {
      return [NSError errorWithDomain:FSLPromiseErrorDomain code:42 userInfo:nil];
    }
    ++count;
    return [partialString stringByAppendingString:nextNumber.stringValue];
  }] then:^id(id __unused _) {
    XCTFail();
    return nil;
  }] catch:^(NSError *error) {
    XCTAssertEqual(error.code, 42);
    ++count;
  }];

  // Assert.
  XCTAssert(FSLWaitForPromisesWithTimeout(10));
  XCTAssertEqual(count, expectedCount);
}

@end
