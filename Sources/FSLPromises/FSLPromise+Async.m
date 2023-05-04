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

#import "FSLPromise+Async.h"

#import "FSLPromisePrivate.h"

@implementation FSLPromise (AsyncAdditions)

+ (instancetype)async:(FSLPromiseAsyncWorkBlock)work {
  return [self onQueue:self.defaultDispatchQueue async:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue async:(FSLPromiseAsyncWorkBlock)work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  FSLPromise *promise = [[self alloc] initPending];
  dispatch_group_async(FSLPromise.dispatchGroup, queue, ^{
    work(
        ^(id __nullable value) {
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
        },
        ^(NSError *error) {
          [promise reject:error];
        });
  });
  return promise;
}

@end

@implementation FSLPromise (DotSyntax_AsyncAdditions)

+ (FSLPromise* (^)(FSLPromiseAsyncWorkBlock))async {
  return ^(FSLPromiseAsyncWorkBlock work) {
    return [self async:work];
  };
}

+ (FSLPromise* (^)(dispatch_queue_t, FSLPromiseAsyncWorkBlock))asyncOn {
  return ^(dispatch_queue_t queue, FSLPromiseAsyncWorkBlock work) {
    return [self onQueue:queue async:work];
  };
}

@end
