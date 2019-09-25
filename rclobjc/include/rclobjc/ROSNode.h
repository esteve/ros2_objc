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

#import "rclobjc/ROSClient.h"
#import "rclobjc/ROSPublisher.h"
#import "rclobjc/ROSService.h"
#import "rclobjc/ROSSubscription.h"

@interface ROSNode : NSObject {
  NSString *nodeName;
  NSString *nodeNamespace;
  intptr_t nodeHandle;
  NSMutableSet<ROSSubscription *> *subscriptions;
  NSMutableSet<ROSService *> *services;
  NSMutableSet<ROSClient *> *clients;
}

- (ROSPublisher *)createPublisher:(Class)messageType:(NSString *)topic;

- (ROSSubscription *)createSubscriptionWithCallback:(Class)
                                        messageType:(NSString *)
                                              topic:(void (*)(id))callback;

- (ROSService *)createServiceWithCallback:(Class)
                              serviceType:(NSString *)
                              serviceName:(void (*)(id, id, id))callback;

- (ROSClient *)createClient:(Class)serviceType:(NSString *)serviceName;

- (instancetype)initWithArguments:(NSString *)
                         nodeName:(NSString *)
                    nodeNamespace:(intptr_t)nodeHandle;

@property(readonly) NSString *nodeName;
@property(readonly) NSString *nodeNamespace;
@property(readonly) intptr_t nodeHandle;
@property(retain, nonatomic) NSMutableSet<ROSSubscription *> *subscriptions;
@property(retain, nonatomic) NSMutableSet<ROSService *> *services;
@property(retain, nonatomic) NSMutableSet<ROSClient *> *clients;

@end
