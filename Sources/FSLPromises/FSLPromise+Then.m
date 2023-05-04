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

#import "FSLPromisePrivate.h"

@implementation FSLPromise (ThenAdditions)

- (FSLPromise *)then:(FSLPromiseThenWorkBlock)work {
  return [self onQueue:FSLPromise.defaultDispatchQueue then:work];
}

- (FSLPromise *)onQueue:(dispatch_queue_t)queue then:(FSLPromiseThenWorkBlock)work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  return [self chainOnQueue:queue chainedFulfill:work chainedReject:nil];
}

@end

@implementation FSLPromise (DotSyntax_ThenAdditions)

- (FSLPromise* (^)(FSLPromiseThenWorkBlock))then {
  return ^(FSLPromiseThenWorkBlock work) {
    return [self then:work];
  };
}

- (FSLPromise* (^)(dispatch_queue_t, FSLPromiseThenWorkBlock))thenOn {
  return ^(dispatch_queue_t queue, FSLPromiseThenWorkBlock work) {
    return [self onQueue:queue then:work];
  };
}

@end
