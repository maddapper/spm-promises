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

#import "FSLPromisePrivate.h"

@implementation FSLPromise (ValidateAdditions)

- (FSLPromise*)validate:(FSLPromiseValidateWorkBlock)predicate {
  return [self onQueue:FSLPromise.defaultDispatchQueue validate:predicate];
}

- (FSLPromise*)onQueue:(dispatch_queue_t)queue validate:(FSLPromiseValidateWorkBlock)predicate {
  NSParameterAssert(queue);
  NSParameterAssert(predicate);

  FSLPromiseChainedFulfillBlock chainedFulfill = ^id(id value) {
    return predicate(value) ? value :
                              [[NSError alloc] initWithDomain:FSLPromiseErrorDomain
                                                         code:FSLPromiseErrorCodeValidationFailure
                                                     userInfo:nil];
  };
  return [self chainOnQueue:queue chainedFulfill:chainedFulfill chainedReject:nil];
}

@end

@implementation FSLPromise (DotSyntax_ValidateAdditions)

- (FSLPromise* (^)(FSLPromiseValidateWorkBlock))validate {
  return ^(FSLPromiseValidateWorkBlock predicate) {
    return [self validate:predicate];
  };
}

- (FSLPromise* (^)(dispatch_queue_t, FSLPromiseValidateWorkBlock))validateOn {
  return ^(dispatch_queue_t queue, FSLPromiseValidateWorkBlock predicate) {
    return [self onQueue:queue validate:predicate];
  };
}

@end
