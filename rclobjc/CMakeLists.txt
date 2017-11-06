cmake_minimum_required(VERSION 3.5)

project(rclobjc C)

find_package(ament_cmake_ros REQUIRED)
find_package(rcl REQUIRED)
find_package(rcl_interfaces REQUIRED)
find_package(rmw REQUIRED)
find_package(rmw_implementation REQUIRED)
find_package(rmw_implementation_cmake REQUIRED)
find_package(rosidl_generator_c REQUIRED)

find_package(rclobjc_common REQUIRED)
include(UseObjectiveC)

include_directories(include)

set(${PROJECT_NAME}_SRCS
  "src/ROSClient.m"
  "src/ROSNode.m"
  "src/ROSPublisher.m"
  "src/ROSRCLObjC.m"
  "src/ROSService.m"
  "src/ROSSubscription.m"
)

add_library(${PROJECT_NAME}
  ${${PROJECT_NAME}_SRCS})

target_link_libraries(${PROJECT_NAME} "${OBJC_LIBRARIES}")
set_target_properties(${PROJECT_NAME} PROPERTIES
  COMPILE_FLAGS "${OBJC_FLAGS}")

ament_target_dependencies(${PROJECT_NAME}
  "builtin_interfaces"
  "rcl"
  "rosidl_generator_c"
  "rosidl_typesupport_c")

install(
  TARGETS ${PROJECT_NAME}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

ament_export_dependencies(ament_cmake_ros)
ament_export_dependencies(builtin_interfaces)
ament_export_dependencies(rcl)
ament_export_dependencies(rosidl_generator_c)
ament_export_dependencies(rosidl_typesupport_c)
ament_export_dependencies(rosidl_typesupport_c)

ament_export_include_directories(include)

ament_export_libraries(${PROJECT_NAME})

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()

install(
  DIRECTORY include/
  DESTINATION include
)
