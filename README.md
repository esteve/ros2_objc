ROS2 for Objective C and iOS
============================

Introduction
------------

This is a set of projects (bindings, code generator, examples and more) that enables developers to write ROS2
applications in Objective C on macOS and iOS (iPhone, iPad)

Besides this repository itself, there's also:
- https://github.com/esteve/ros2_ios_examples, examples for iOS
- https://github.com/esteve/ros2_objc_examples, examples for macOS

Additionally, there is a collection of pull requests for ROS2 that are needed for RCLObjC to work on macOS and iOS:

[rmw_fastrtps] Export FastRTPS libraries

https://github.com/ros2/rmw_fastrtps/pull/75

[rmw] Add support for pthread-based thread local storage

https://github.com/ros2/rmw/pull/80

[ament_tools] Use Xcode as system generator and builder on OSX

https://github.com/ament/ament_tools/pull/127

[ament_tools] Build shared libraries by default, but honor BUILD_SHARED_LIBS

https://github.com/ament/ament_tools/pull/128

[Fast-CDR] Control shared/static linking via EPROSIMA_HONOR_BUILD_SHARED_LIBS and BUILD_SHARED_LIBS

https://github.com/eProsima/Fast-CDR/pull/8

[rcl] Control shared/static linking via BUILD_SHARED_LIBS

https://github.com/ros2/rcl/pull/93

[rmw] Control shared/static linking via BUILD_SHARED_LIBS

https://github.com/ros2/rmw/pull/81

[rosidl] Control shared/static linking via BUILD_SHARED_LIBS

https://github.com/ros2/rosidl/pull/183

Does this support Swift?
------------------------

Yes. I decided to target Objective C since I found it is easier to build Swift applications on top of Objective C, than the opposite.

Does this work on iOS?
----------------------

Yep! Make sure to use [this fork](https://github.com/eProsima/Fast-RTPS/pull/26) as your DDS vendor. Even though the name of the branch is "cpp11-android", I ended up adding support for iOS on top of it.

Features
--------

The current set of features include:
- Generation of all builtin ROS types
- Support for publishers and subscriptions
- Clients and services
- Support for iOS (iPhone, iPad)

Sounds great, how can I try this out?
-------------------------------------

The following steps show how to build the examples for both macOS and iOS.

macOS
-----

```
mkdir -p ~/ros2_objc_ws/src
cd ~/ros2_objc_ws
wget https://raw.githubusercontent.com/esteve/ros2_objc/master/ros2_objc_macos.repos
vcs import ~/ros2_objc_ws/src < ros2_objc_macos.repos
src/ament/ament_tools/scripts/ament.py build --isolated
```

Now you can just run a bunch of examples.

### Talker and Listener

Talker:

```
. ~/ros2_objc_ws/install_isolated/local_setup.sh

ROSTalker
```

Listener:

```
. ~/ros2_objc_ws/install_isolated/local_setup.sh

ROSListener
```

### Client and Service

Service:

```
. ~/ros2_objc_ws/install_isolated/local_setup.sh

ROSAddTwoIntsService
```

Client:

```
. ~/ros2_objc_ws/install_isolated/local_setup.sh

ROSAddTwoIntsClientAsync
```

You can also combine any scenario where the talker/listener or client/service are written in Objective C, Java, Python and C++ and they should talk to each other.

iOS
---

The iOS setup is slightly more complex. If you do not have a jailbroken device, you will have to sign the resulting apps, which is much easier to do on Xcode's IDE than the command line.

The following was tested on an iPhone 5C running iOS 9.1.

```
mkdir -p ~/ros2_ios_ws/src
cd ~/ros2_ios_ws
wget https://raw.githubusercontent.com/esteve/ros2_objc/master/ros2_objc_ios.repos
vcs import ~/ros2_ios_ws/src < ros2_objc_ios.repos
touch ~/ros2_ios_ws/src/ros2/rosidl/python_cmake_module/AMENT_IGNORE
touch ~/ros2_ios_ws/src/ros2/rosidl/rosidl_generator_py/AMENT_IGNORE
touch ~/ros2_ios_ws/src/ruslo/polly/examples/01-executable/AMENT_IGNORE
touch ~/ros2_ios_ws/src/ruslo/polly/examples/02-library/AMENT_IGNORE
touch ~/ros2_ios_ws/src/ruslo/polly/examples/03-shared-link/AMENT_IGNORE
cd ~/ros2_ios_ws/src/eProsima/Fast-RTPS-ios
git submodule init
git submodule update
cd ~/ros2_ios_ws

# Use the latest version of the iOS SDK (replace "." with "-") that your XCode installation supports, even if you plan to deploy the examples on an an older device
export ROS2_IOS_VERSION="10-1"
export XCODE_XCCONFIG_FILE=$HOME/ros2_ios_ws/src/ruslo/polly/scripts/NoCodeSign.xcconfig

src/ament/ament_tools/scripts/ament.py build \
  --isolated \
  --cmake-args \
  -DTHIRDPARTY=ON -DCOMPILE_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DEPROSIMA_HONOR_BUILD_SHARED_LIBS=ON -DCMAKE_TOOLCHAIN_FILE=$HOME/ros2_ios_ws/src/ruslo/polly/ios-nocodesign-"$ROS2_IOS_VERSION".cmake -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO -- \
  --ament-cmake-args \
  -DTHIRDPARTY=ON -DCOMPILE_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DEPROSIMA_HONOR_BUILD_SHARED_LIBS=ON -DCMAKE_TOOLCHAIN_FILE=$HOME/ros2_ios_ws/src/ruslo/polly/ios-nocodesign-"$ROS2_IOS_VERSION".cmake -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO -- \
  --make-flags -sdk iphoneos
```

If you want to run the examples on the iOS Simulator, just replace `-sdk iphoneos` with `-sdk iphonesimulator` on the command above.

You will now have the supporting static libraries in ~/ros2_ios_ws/install_isolated, so now we need to properly build the examples for iOS and sign them.

Let's fire up XCode, build the talker and listener examples, and install them onto our device.

Talker:

```
cd ~/ros2_ios_ws

open src/ros2_objc/ros2_ios_examples/ros2_listener_ios/Listener/Listener.xcodeproj
```

Pick your device from the dropdown next to the "Build" button (the one that looks like a "Play" icon) icon and press "Build". Make sure to choose an appropriate development team to sign the app.

Talker:

```
cd ~/ros2_ios_ws

open src/ros2_objc/ros2_ios_examples/ros2_talker_ios/Talker/Talker.xcodeproj
```

Again, choose a valid development team so Xcode can sign the app.

You can try out running the talker on the desktop and the listener on your iOS device or viceversa. Or if you happen to have an Android device, follow the instructions on http://github.com/esteve/ros2_java and have your mobile devices talk to each other :-)

Enjoy!

TODO
----

- Support nested types, constant values and lists in the generator
- Support QoS in rclobjc
- Provide instructions for integrating with Swift
- Add tests
- Add tutorial for developing ROS2/iOS applications from scratch that
