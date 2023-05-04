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

#import "FSLPromise+Do.h"

#import "FSLPromisePrivate.h"

@implementation FSLPromise (DoAdditions)

+ (instancetype)do:(FSLPromiseDoWorkBlock)work {
  return [self onQueue:self.defaultDispatchQueue do:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue do:(FSLPromiseDoWorkBlock)work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  FSLPromise *promise = [[self alloc] initPending];
  dispatch_group_async(FSLPromise.dispatchGroup, queue, ^{
    id value = work();
    if ([value isKindOfClass:[FSLPromise class]]) {
      [(FSLPromise *)value observeOnQueue:queue
          fulfill:^(id __nullable value) {
            [promise fulfill:value];
          }
          reject:^(NSError *error) {
            [promise reject:error];
          }];
    } else {
      [promise fulfill:value];
    }
  });
  return promise;
}

@end

@implementation FSLPromise (DotSyntax_DoAdditions)

+ (FSLPromise* (^)(dispatch_queue_t, FSLPromiseDoWorkBlock))doOn {
  return ^(dispatch_queue_t queue, FSLPromiseDoWorkBlock work) {
    return [self onQueue:queue do:work];
  };
}

@end
