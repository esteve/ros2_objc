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

#include <rmw/rmw.h>
#include <rcl/error_handling.h>
#include <rcl/rcl.h>
#include <rcl/node.h>
#include <rosidl_generator_c/message_type_support.h>
#include <stdlib.h>

#import "rclobjc/ROSRCLObjC.h"
#import "rclobjc/ROSNode.h"

@interface ROSRCLObjC ()

+(intptr_t)createNodeHandle :(NSString *)nodeName;

@end

@implementation ROSRCLObjC

+(bool)ok {
  return rcl_ok();
}

+(void)rclInit {
  rcl_ret_t ret = rcl_init(0, NULL, rcl_get_default_allocator());
  if (ret != RCL_RET_OK) {
  // TODO(esteve): check return status
  }
}

+(ROSNode *)createNode :(NSString *)nodeName {
  intptr_t nodeHandle = [ROSRCLObjC createNodeHandle:nodeName];
  ROSNode * node = [[ROSNode alloc] initWithNameAndHandle:nodeName :nodeHandle ];
  return node;
}

+(intptr_t)createNodeHandle :(NSString *)nodeName {
  const char * node_name_tmp = [nodeName UTF8String];

  rcl_node_t * node = (rcl_node_t *)malloc(sizeof(rcl_node_t));
  node->impl = NULL;
  rcl_node_options_t default_options = rcl_node_get_default_options();
  rcl_ret_t ret = rcl_node_init(node, node_name_tmp, &default_options);
  if (ret != RCL_RET_OK) {
    // TODO(esteve): check return status
    return 0;
  }
  intptr_t node_handle = (intptr_t)node;
  return node_handle;
}

+(void)spinOnce :(ROSNode *)node {

    rcl_wait_set_t wait_set = rcl_get_zero_initialized_wait_set();

    int number_of_subscriptions = [[node subscriptions] count];
    int number_of_guard_conditions = 0;
    int number_of_timers = 0;
    int number_of_clients = [[node clients] count];
    int number_of_services = [[node services] count];

    rcl_ret_t ret = rcl_wait_set_init(
      &wait_set, number_of_subscriptions, number_of_guard_conditions, number_of_timers,
      number_of_clients, number_of_services, rcl_get_default_allocator());
    if (ret != RCL_RET_OK) {
      // TODO(esteve): handle error
      assert(false);
      return;
    }

    ret = rcl_wait_set_clear_subscriptions(&wait_set);
    if (ret != RCL_RET_OK) {
      // TODO(esteve): handle error
      assert(false);
      return;
    }

    ret = rcl_wait_set_clear_services(&wait_set);
    if (ret != RCL_RET_OK) {
      // TODO(esteve): handle error
      assert(false);
      return;
    }

    ret = rcl_wait_set_clear_clients(&wait_set);
    if (ret != RCL_RET_OK) {
      // TODO(esteve): handle error
      assert(false);
      return;
    }

    for (ROSSubscription * rosSubscription in [node subscriptions]) {
      rcl_subscription_t * subscription = (rcl_subscription_t *)[rosSubscription subscriptionHandle];
      ret = rcl_wait_set_add_subscription(&wait_set, subscription);
      if (ret != RCL_RET_OK) {
        // TODO(esteve): handle error
        assert(false);
        return;
      }
    }

    for (ROSService * rosService in [node services]) {
      rcl_service_t * service = (rcl_service_t *)[rosService serviceHandle];
      ret = rcl_wait_set_add_service(&wait_set, service);
      if (ret != RCL_RET_OK) {
        // TODO(esteve): handle error
        assert(false);
        return;
      }
    }

    for (ROSClient * rosClient in [node clients]) {
      rcl_client_t * client = (rcl_client_t *)[rosClient clientHandle];
      ret = rcl_wait_set_add_client(&wait_set, client);
      if (ret != RCL_RET_OK) {
        // TODO(esteve): handle error
        assert(false);
        return;
      }
    }

    ret = rcl_wait(&wait_set, RCL_S_TO_NS(1));
    if (ret != RCL_RET_OK && ret != RCL_RET_TIMEOUT) {
      // TODO(esteve): handle error
      assert(false);
      return;
    }

    for (ROSSubscription * rosSubscription in [node subscriptions]) {
      rcl_subscription_t * subscription = (rcl_subscription_t *)[rosSubscription subscriptionHandle];

      intptr_t from_converter_ptr = [[rosSubscription messageType] fromObjcConverterPtr];

      assert(from_converter_ptr != 0);

      typedef void * (* convert_from_objc_signature)(NSObject *);
      convert_from_objc_signature convert_from_objc =
        (convert_from_objc_signature)from_converter_ptr;

      NSObject * msg_tmp = [[[rosSubscription messageType] alloc] init];

      NSObject * message = NULL;

      void * taken_msg = convert_from_objc(msg_tmp);

      assert(taken_msg != NULL);

      rcl_ret_t ret = rcl_take(subscription, taken_msg, NULL);

      if (ret != RCL_RET_OK && ret != RCL_RET_SUBSCRIPTION_TAKE_FAILED) {
        // TODO(esteve): handle error
        assert(false);
        return;
      }

      if (ret != RCL_RET_SUBSCRIPTION_TAKE_FAILED) {

        intptr_t to_converter_ptr = [[rosSubscription messageType] toObjcConverterPtr];

        assert(to_converter_ptr != 0);

        typedef NSObject * (* convert_to_objc_signature)(void *);
        convert_to_objc_signature convert_to_objc =
          (convert_to_objc_signature)to_converter_ptr;

        message = convert_to_objc(taken_msg);
      }

      if (message != NULL) {
        assert([rosSubscription callback] != NULL);
        assert([rosSubscription callback] != nil);
        [rosSubscription callback](message);
      }
    }

    for (ROSClient * rosClient in [node clients]) {
      rcl_client_t * client = (rcl_client_t *)[rosClient clientHandle];

      Class requestType = [[rosClient serviceType] requestType];
      Class responseType = [[rosClient serviceType] responseType];

      intptr_t requestFromObjcConverterHandle = [requestType fromObjcConverterPtr];
      intptr_t requestToObjcConverterHandle = [requestType toObjcConverterPtr];
      intptr_t responseFromObjcConverterHandle = [responseType fromObjcConverterPtr];
      intptr_t responseToObjcConverterHandle = [responseType toObjcConverterPtr];

      assert(requestFromObjcConverterHandle != 0);
      assert(requestToObjcConverterHandle != 0);
      assert(responseFromObjcConverterHandle != 0);
      assert(responseToObjcConverterHandle != 0);

      NSObject * requestMessage = [[requestType alloc] init];
      NSObject * responseMessage = [[responseType alloc] init];

      typedef void * (* convert_from_objc_signature)(NSObject *);
      typedef NSObject * (* convert_to_objc_signature)(void *);

      convert_from_objc_signature convert_request_from_objc =
        (convert_from_objc_signature)requestFromObjcConverterHandle;

      convert_from_objc_signature convert_response_from_objc =
        (convert_from_objc_signature)responseFromObjcConverterHandle;

      convert_to_objc_signature convert_request_to_objc =
        (convert_to_objc_signature)requestToObjcConverterHandle;

      convert_to_objc_signature convert_response_to_objc =
        (convert_to_objc_signature)responseToObjcConverterHandle;

      void * service_response = convert_response_from_objc(responseMessage);

      rmw_request_id_t header;
      ret = rcl_take_response(client, &header, service_response);

      if (ret != RCL_RET_OK && ret != RCL_RET_CLIENT_TAKE_FAILED) {
        // TODO(esteve) handle error
        assert(false);
      }

      if (ret != RCL_RET_CLIENT_TAKE_FAILED) {
        NSObject * otaken_msg = convert_response_to_objc(service_response);

        assert(otaken_msg != NULL);
        assert(otaken_msg != nil);

        [rosClient handleResponse :header.sequence_number :otaken_msg];
      }
    }

    for (ROSService * rosService in [node services]) {
      rcl_service_t * service = (rcl_service_t *)[rosService serviceHandle];

      Class requestType = [[rosService serviceType] requestType];
      Class responseType = [[rosService serviceType] responseType];

      intptr_t requestFromObjcConverterHandle = [requestType fromObjcConverterPtr];
      intptr_t requestToObjcConverterHandle = [requestType toObjcConverterPtr];
      intptr_t responseFromObjcConverterHandle = [responseType fromObjcConverterPtr];
      intptr_t responseToObjcConverterHandle = [responseType toObjcConverterPtr];

      assert(requestFromObjcConverterHandle != 0);
      assert(requestToObjcConverterHandle != 0);
      assert(responseFromObjcConverterHandle != 0);
      assert(responseToObjcConverterHandle != 0);

      NSObject * requestMessage = [[requestType alloc] init];
      NSObject * responseMessage = [[responseType alloc] init];

      typedef void * (* convert_from_objc_signature)(NSObject *);
      typedef NSObject * (* convert_to_objc_signature)(void *);

      convert_from_objc_signature convert_request_from_objc =
        (convert_from_objc_signature)requestFromObjcConverterHandle;

      convert_from_objc_signature convert_response_from_objc =
        (convert_from_objc_signature)responseFromObjcConverterHandle;

      convert_to_objc_signature convert_request_to_objc =
        (convert_to_objc_signature)requestToObjcConverterHandle;

      convert_to_objc_signature convert_response_to_objc =
        (convert_to_objc_signature)responseToObjcConverterHandle;

      void * service_request = convert_request_from_objc(requestMessage);

      rmw_request_id_t header;
      ret = rcl_take_request(service, &header, service_request);

      if (ret != RCL_RET_OK && ret != RCL_RET_SERVICE_TAKE_FAILED) {
        // TODO(esteve) handle error
        assert(false);
      }

      if (ret != RCL_RET_SERVICE_TAKE_FAILED) {
        NSObject * otaken_msg = convert_request_to_objc(service_request);

        assert(otaken_msg != NULL);
        assert(otaken_msg != nil);

        [rosService callback](&header, otaken_msg, responseMessage);

        void * service_response = convert_response_from_objc(responseMessage);

        ret = rcl_send_response(service, &header, service_response);

        assert(ret == RCL_RET_OK);
      }
    }

}

@end
