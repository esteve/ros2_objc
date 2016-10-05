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

#import "rclobjc/ROSSubscription.h"

@interface ROSSubscription()

@property (assign) intptr_t nodeHandle;
@property (assign) intptr_t subscriptionHandle;
@property (assign) NSString *topic;
@property (assign) void (^callback)(NSObject *);
@property (assign) Class messageType;

@end

@implementation ROSSubscription
-(instancetype)initWithArguments :(intptr_t)nodeHandle :(intptr_t)subscriptionHandle :(NSString *)topic :(Class)messageType :(void(^)(NSObject *))callback {
  self.nodeHandle = nodeHandle;
  self.subscriptionHandle = subscriptionHandle;
  self.topic = topic;
  self.messageType = messageType;
  self.callback = callback;
  return self;
}
@end
