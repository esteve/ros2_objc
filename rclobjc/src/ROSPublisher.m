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

#include "rmw/rmw.h"
#include "rcl/error_handling.h"
#include "rcl/rcl.h"
#include "rcl/node.h"

#import "rclobjc/ROSPublisher.h"

@interface ROSPublisher()

@property (assign) intptr_t nodeHandle;
@property (assign) intptr_t publisherHandle;
@property (assign) NSString *topic;

@end

@implementation ROSPublisher
-(void)publish:(id)message {
  rcl_publisher_t * publisher = (rcl_publisher_t *)self.publisherHandle;

  // TODO(esteve): move messageType as a property
  //intptr_t converter_ptr = [[message class] performSelector:@selector(fromObjcConverterPtr)];
  intptr_t converter_ptr = [[message class] fromObjcConverterPtr];

  typedef void * (* convert_from_objc_signature)(void *);
  convert_from_objc_signature convert_from_objc =
    (convert_from_objc_signature)converter_ptr;

  void * raw_ros_message = convert_from_objc(message);
  rcl_ret_t ret = rcl_publish(publisher, raw_ros_message);
  if (ret != RCL_RET_OK) {
    // TODO(esteve): handle error
  }
}

-(instancetype)initWithArguments: (intptr_t)nodeHandle :(intptr_t)publisherHandle :(NSString *)topic {
  self.nodeHandle = nodeHandle;
  self.publisherHandle = publisherHandle;
  self.topic = topic;
  return self;
}
@end
