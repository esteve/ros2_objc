cmake_minimum_required(VERSION 3.5)

project(rclobjc_common)

find_package(ament_cmake REQUIRED)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package(
  CONFIG_EXTRAS "rclobjc_cmake_module-extras.cmake.in"
)

install(DIRECTORY cmake
  DESTINATION share/${PROJECT_NAME}
)
