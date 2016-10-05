cmake_minimum_required(VERSION 3.5)

project(rclobjc C)

find_package(ament_cmake REQUIRED)
find_package(rcl REQUIRED)
find_package(rcl_interfaces REQUIRED)
find_package(rmw REQUIRED)
find_package(rmw_implementation REQUIRED)
find_package(rmw_implementation_cmake REQUIRED)
find_package(rosidl_generator_c REQUIRED)

include_directories(include)

set(${PROJECT_NAME}_SRCS
  "src/ROSClient.m"
  "src/ROSNode.m"
  "src/ROSPublisher.m"
  "src/ROSRCLObjC.m"
  "src/ROSService.m"
  "src/ROSSubscription.m"
)

ament_export_dependencies(ament_cmake)
ament_export_dependencies(rcl)
ament_export_dependencies(rosidl_generator_c)

ament_export_include_directories(include)

ament_export_libraries(${PROJECT_NAME})

macro(target)
  if(NOT target_suffix STREQUAL "")
    get_rcl_information("${rmw_implementation}" "rcl${target_suffix}")
  endif()
  add_library(${PROJECT_NAME}${target_suffix}
    ${${PROJECT_NAME}_SRCS})
  target_link_libraries(${PROJECT_NAME}${target_suffix} "-framework Foundation")

  ament_target_dependencies(${PROJECT_NAME}${target_suffix}
    "rcl${target_suffix}")

  install(
    TARGETS ${PROJECT_NAME}${target_suffix}
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
  )
endmacro()

call_for_each_rmw_implementation(target GENERATE_DEFAULT)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()

install(
  DIRECTORY include/
  DESTINATION include
)
