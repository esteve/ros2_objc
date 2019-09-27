/* Copyright 2016 Esteve Fernandez <esteve@apache.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

typedef void (*ROSServiceCallbackType)(NSObject *, NSObject *, NSObject *);

@interface FunctionPointerContainer:NSObject {
   ROSServiceCallbackType funtionPointer;
}

- (instancetype)initWithArguments: (ROSServiceCallbackType)init_funtionPointer;
- (ROSServiceCallbackType)getFunctionPointer;

@property(readonly) ROSServiceCallbackType funtionPointer;

@end

@interface ROSClient<MessageType> : NSObject {
  intptr_t nodeHandle;
  intptr_t clientHandle;
  Class serviceType;
  NSString *serviceName;
  Class requestType;
  Class responseType;
  NSMutableDictionary<NSNumber *, FunctionPointerContainer *> *pendingRequests;
}

- (instancetype)initWithArguments:(intptr_t)
                       nodeHandle:(intptr_t)
                     clientHandle:(Class)
                      serviceType:(NSString *)serviceName;

- (void)sendRequest:(id)request:(ROSServiceCallbackType)callback;

- (void)handleResponse:(int64_t)sequenceNumber:(id)response;

@property(readonly) intptr_t nodeHandle;
@property(readonly) intptr_t clientHandle;
@property(readonly) Class serviceType;
@property(readonly) NSString *serviceName;
@property(readonly) Class requestType;
@property(readonly) Class responseType;

@end
