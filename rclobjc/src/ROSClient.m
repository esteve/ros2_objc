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

#include "rcl/error_handling.h"
#include "rcl/node.h"
#include "rcl/rcl.h"
#include "rmw/rmw.h"

#import "rclobjc/ROSClient.h"

@interface ROSClient ()

@property(assign) intptr_t nodeHandle;
@property(assign) intptr_t clientHandle;
@property(assign) Class serviceType;
@property(assign) NSString *serviceName;
@property(assign) Class requestType;
@property(assign) Class responseType;
@property(assign)
    NSMutableDictionary<NSNumber *, void (*)(id)> *pendingRequests;
    
@end

@implementation ROSClient

@synthesize nodeHandle;
@synthesize clientHandle;
@synthesize serviceType;
@synthesize serviceName;
@synthesize requestType;
@synthesize responseType;
@synthesize pendingRequests;

- (instancetype)initWithArguments:(intptr_t)
                       nodeHandle:(intptr_t)
                     clientHandle:(Class)
                      serviceType:(NSString *)serviceName {
  self.nodeHandle = nodeHandle;
  self.clientHandle = clientHandle;
  self.serviceType = serviceType;
  self.serviceName = serviceName;
  self.requestType = [serviceType requestType];
  self.responseType = [serviceType responseType];
  self.pendingRequests = [[NSMutableDictionary alloc] init];

  assert(clientHandle != 0);

  return self;
}

- (void)sendRequest:(id)request:(void (*)(id))callback {
  rcl_client_t *client = (rcl_client_t *)self.clientHandle;

  typedef void *(*convert_from_objc_signature)(NSObject *);

  intptr_t requestFromObjcConverterHandle =
      [self.requestType fromObjcConverterPtr];

  convert_from_objc_signature convert_request_from_objc =
      (convert_from_objc_signature)requestFromObjcConverterHandle;

  void *ros_request_msg = convert_request_from_objc(request);

  int64_t sequence_number = 0;

  rcl_ret_t ret = rcl_send_request(client, ros_request_msg, &sequence_number);

  [self.pendingRequests setObject:callback
                           forKey:[NSNumber numberWithInteger:sequence_number]];
  assert(ret == RCL_RET_OK);
}

- (void)handleResponse:(int64_t)sequenceNumber:(id)response {
  NSNumber *nsseq = [NSNumber numberWithInteger:sequenceNumber];
  // void(*callback)(id) = self.pendingRequests[nsseq];
  void (*callback)(id) = [self.pendingRequests objectForKey:nsseq];
  [self.pendingRequests removeObjectForKey:nsseq];
  callback(response);
}
@end
