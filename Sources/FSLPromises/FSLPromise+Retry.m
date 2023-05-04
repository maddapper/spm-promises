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

#import "FSLPromisePrivate.h"

NSInteger const FSLPromiseRetryDefaultAttemptsCount = 1;
NSTimeInterval const FSLPromiseRetryDefaultDelayInterval = 1.0;

static void FSLPromiseRetryAttempt(FSLPromise *promise, dispatch_queue_t queue, NSInteger count,
                                   NSTimeInterval interval, FSLPromiseRetryPredicateBlock predicate,
                                   FSLPromiseRetryWorkBlock work) {
  __auto_type retrier = ^(id __nullable value) {
    if ([value isKindOfClass:[NSError class]]) {
      if (count <= 0 || (predicate && !predicate(count, value))) {
        [promise reject:value];
      } else {
        dispatch_after(dispatch_time(0, (int64_t)(interval * NSEC_PER_SEC)), queue, ^{
          FSLPromiseRetryAttempt(promise, queue, count - 1, interval, predicate, work);
        });
      }
    } else {
      [promise fulfill:value];
    }
  };
  id value = work();
  if ([value isKindOfClass:[FSLPromise class]]) {
    [(FSLPromise *)value observeOnQueue:queue fulfill:retrier reject:retrier];
  } else  {
    retrier(value);
  }
}

@implementation FSLPromise (RetryAdditions)

+ (instancetype)retry:(FSLPromiseRetryWorkBlock)work {
  return [self onQueue:FSLPromise.defaultDispatchQueue retry:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue retry:(FSLPromiseRetryWorkBlock)work {
  return [self onQueue:queue attempts:FSLPromiseRetryDefaultAttemptsCount retry:work];
}

+ (instancetype)attempts:(NSInteger)count retry:(FSLPromiseRetryWorkBlock)work {
  return [self onQueue:FSLPromise.defaultDispatchQueue attempts:count retry:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
               attempts:(NSInteger)count
                  retry:(FSLPromiseRetryWorkBlock)work {
  return [self onQueue:queue
              attempts:count
                 delay:FSLPromiseRetryDefaultDelayInterval
             condition:nil
                 retry:work];
}

+ (instancetype)attempts:(NSInteger)count
                   delay:(NSTimeInterval)interval
               condition:(nullable FSLPromiseRetryPredicateBlock)predicate
                   retry:(FSLPromiseRetryWorkBlock)work {
  return [self onQueue:FSLPromise.defaultDispatchQueue
              attempts:count
                 delay:interval
             condition:predicate
                 retry:work];
}

+ (instancetype)onQueue:(dispatch_queue_t)queue
               attempts:(NSInteger)count
                  delay:(NSTimeInterval)interval
              condition:(nullable FSLPromiseRetryPredicateBlock)predicate
                  retry:(FSLPromiseRetryWorkBlock)work {
  NSParameterAssert(queue);
  NSParameterAssert(work);

  FSLPromise *promise = [[self alloc] initPending];
  FSLPromiseRetryAttempt(promise, queue, count, interval, predicate, work);
  return promise;
}

@end

@implementation FSLPromise (DotSyntax_RetryAdditions)

+ (FSLPromise * (^)(FSLPromiseRetryWorkBlock))retry {
  return ^id(FSLPromiseRetryWorkBlock work) {
    return [self retry:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t, FSLPromiseRetryWorkBlock))retryOn {
  return ^id(dispatch_queue_t queue, FSLPromiseRetryWorkBlock work) {
    return [self onQueue:queue retry:work];
  };
}

+ (FSLPromise * (^)(NSInteger, NSTimeInterval, FSLPromiseRetryPredicateBlock,
                    FSLPromiseRetryWorkBlock))retryAgain {
  return ^id(NSInteger count, NSTimeInterval interval, FSLPromiseRetryPredicateBlock predicate,
             FSLPromiseRetryWorkBlock work) {
    return [self attempts:count delay:interval condition:predicate retry:work];
  };
}

+ (FSLPromise * (^)(dispatch_queue_t, NSInteger, NSTimeInterval, FSLPromiseRetryPredicateBlock,
                    FSLPromiseRetryWorkBlock))retryAgainOn {
  return ^id(dispatch_queue_t queue, NSInteger count, NSTimeInterval interval,
             FSLPromiseRetryPredicateBlock predicate, FSLPromiseRetryWorkBlock work) {
    return [self onQueue:queue attempts:count delay:interval condition:predicate retry:work];
  };
}

@end
