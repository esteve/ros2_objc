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

#import <objc/runtime.h>

#include <rcl/rcl.h>

#import "rclobjc/ROSNode.h"
#import "rclobjc/ROSService.h"
#import "rclobjc/ROSSubscription.h"

@interface ROSNode ()
+ (intptr_t)createPublisherHandle:(intptr_t)
                       nodeHandle:(Class)
                      messageType:(NSString *)topic;
+ (intptr_t)createSubscriptionHandle:(intptr_t)
                          nodeHandle:(Class)
                         messageType:(NSString *)topic;
+ (intptr_t)createServiceHandle:(intptr_t)
                     nodeHandle:(Class)
                    serviceType:(NSString *)serviceName;

@property NSString *nodeName;
@property NSString *nodeNamespace;
@property intptr_t nodeHandle;

@end

@implementation ROSNode

@synthesize nodeName;
@synthesize nodeNamespace;
@synthesize nodeHandle;
@synthesize subscriptions;
@synthesize services;
@synthesize clients;

+ (intptr_t)createPublisherHandle:(intptr_t)
                       nodeHandle:(Class)
                      messageType:(NSString *)topic {
  intptr_t typesupportHandle = [messageType typesupportHandle];

  const char *topic_tmp = [topic UTF8String];

  rcl_node_t *node = (rcl_node_t *)nodeHandle;

  rcl_publisher_t *publisher =
      (rcl_publisher_t *)malloc(sizeof(rcl_publisher_t));
  publisher->impl = NULL;
  rcl_publisher_options_t publisher_ops = rcl_publisher_get_default_options();

  rosidl_message_type_support_t *ts =
      (rosidl_message_type_support_t *)typesupportHandle;

  rcl_ret_t ret =
      rcl_publisher_init(publisher, node, ts, topic_tmp, &publisher_ops);

  if (ret != RCL_RET_OK) {
    // TODO(esteve): handle error
    return 0;
  }

  intptr_t publisherHandle = (intptr_t)publisher;
  return publisherHandle;
}

+ (intptr_t)createSubscriptionHandle:(intptr_t)
                          nodeHandle:(Class)
                         messageType:(NSString *)topic {
  intptr_t typesupportHandle = [messageType typesupportHandle];

  const char *topic_tmp = [topic UTF8String];

  rcl_node_t *node = (rcl_node_t *)nodeHandle;

  rcl_subscription_t *subscription =
      (rcl_subscription_t *)malloc(sizeof(rcl_subscription_t));
  subscription->impl = NULL;
  rcl_subscription_options_t subscription_ops =
      rcl_subscription_get_default_options();

  rosidl_message_type_support_t *ts =
      (rosidl_message_type_support_t *)typesupportHandle;

  rcl_ret_t ret = rcl_subscription_init(subscription, node, ts, topic_tmp,
                                        &subscription_ops);

  if (ret != RCL_RET_OK) {
    // TODO(esteve): handle error
    return 0;
  }

  intptr_t subscriptionHandle = (intptr_t)subscription;
  return subscriptionHandle;
}

+ (intptr_t)createServiceHandle:(intptr_t)
                     nodeHandle:(Class)
                    serviceType:(NSString *)serviceName {
  intptr_t serviceTypesupportHandle = [serviceType serviceTypesupportHandle];

  const char *serviceName_tmp = [serviceName UTF8String];

  rcl_node_t *node = (rcl_node_t *)nodeHandle;

  rcl_service_t *service = (rcl_service_t *)malloc(sizeof(rcl_service_t));
  service->impl = NULL;
  rcl_service_options_t service_ops = rcl_service_get_default_options();

  rosidl_service_type_support_t *ts =
      (rosidl_service_type_support_t *)serviceTypesupportHandle;

  rcl_ret_t ret =
      rcl_service_init(service, node, ts, serviceName_tmp, &service_ops);

  if (ret != RCL_RET_OK) {
    // TODO(esteve): handle error
    assert(false);
    return 0;
  }

  intptr_t serviceHandle = (intptr_t)service;
  return serviceHandle;
}

+ (intptr_t)createClientHandle:(intptr_t)
                    nodeHandle:(Class)
                   serviceType:(NSString *)serviceName {
  intptr_t serviceTypesupportHandle = [serviceType serviceTypesupportHandle];

  const char *serviceName_tmp = [serviceName UTF8String];

  rcl_node_t *node = (rcl_node_t *)nodeHandle;

  rcl_client_t *client = (rcl_client_t *)malloc(sizeof(rcl_client_t));
  client->impl = NULL;
  rcl_client_options_t client_ops = rcl_client_get_default_options();

  rosidl_service_type_support_t *ts =
      (rosidl_service_type_support_t *)serviceTypesupportHandle;

  rcl_ret_t ret =
      rcl_client_init(client, node, ts, serviceName_tmp, &client_ops);

  if (ret != RCL_RET_OK) {
    // TODO(esteve): handle error
    assert(false);
    return 0;
  }

  intptr_t clientHandle = (intptr_t)client;
  return clientHandle;
}

- (ROSPublisher *)createPublisher:(Class)messageType:(NSString *)topic {
  intptr_t publisherHandle =
      [ROSNode createPublisherHandle:self.nodeHandle:messageType:topic];
  ROSPublisher *publisher = [[ROSPublisher alloc] initWithArguments :self.nodeHandle :publisherHandle :topic];
  return publisher;
}

- (ROSSubscription *)createSubscriptionWithCallback:(Class)
                                        messageType:(NSString *)
                                              topic:(void (*)(id))callback {
  intptr_t subscriptionHandle =
      [ROSNode createSubscriptionHandle:self.nodeHandle:messageType:topic];
  ROSSubscription *subscription = [[ROSSubscription alloc] initWithArguments :self.nodeHandle :subscriptionHandle :topic :messageType :callback];
  [[self subscriptions] addObject:subscription];
  return subscription;
}

- (ROSService *)createServiceWithCallback:(Class)
                              serviceType:(NSString *)
                              serviceName:(void (*)(id, id, id))callback {
  intptr_t serviceHandle =
      [ROSNode createServiceHandle:self.nodeHandle:serviceType:serviceName];
  ROSService *service = [[ROSService alloc] initWithArguments :self.nodeHandle :serviceHandle :serviceType :serviceName :callback];
  [[self services] addObject:service];
  return service;
}

- (ROSClient *)createClient:(Class)serviceType:(NSString *)serviceName {
  intptr_t clientHandle =
      [ROSNode createClientHandle:self.nodeHandle:serviceType:serviceName];
  ROSClient *client = [[ROSClient alloc] initWithArguments :self.nodeHandle :clientHandle :serviceType :serviceName];
  [[self clients] addObject:client];
  return client;
}

- (id)initWithArguments:(NSString *)
               nodeName:(NSString *)
          nodeNamespace:(intptr_t)nodeHandle {
  self.nodeName = nodeName;
  self.nodeNamespace = nodeNamespace;
  self.nodeHandle = nodeHandle;
  self.subscriptions = [[NSMutableSet alloc] init];
  self.services = [[NSMutableSet alloc] init];
  self.clients = [[NSMutableSet alloc] init];
  return self;
}
@end
