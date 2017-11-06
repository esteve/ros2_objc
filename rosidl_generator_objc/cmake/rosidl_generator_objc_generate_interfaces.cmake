# Copyright 2016 Esteve Fernandez <esteve@apache.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

find_package(rosidl_generator_c REQUIRED)
find_package(rmw_implementation_cmake REQUIRED)
find_package(rmw REQUIRED)
find_package(rclobjc_common REQUIRED)
include(UseObjectiveC)

# Get a list of typesupport implementations from valid rmw implementations.
rosidl_generator_objc_get_typesupports(_typesupport_impls)

if(_typesupport_impls STREQUAL "")
  message(WARNING "No valid typesupport for Objective C generator. Objective C messages will not be generated.")
  return()
endif()

set(_output_path
  "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_objc/ROS_${PROJECT_NAME}")
set(_generated_msg_objc_files "")
set(_generated_msg_objc_ts_files "")
set(_generated_srv_objc_files "")
set(_generated_srv_objc_ts_files "")
set(_generated_objc_ts_files "")

foreach(_idl_file ${rosidl_generate_interfaces_IDL_FILES})
  get_filename_component(_parent_folder "${_idl_file}" DIRECTORY)
  get_filename_component(_parent_folder "${_parent_folder}" NAME)
  get_filename_component(_module_name "${_idl_file}" NAME_WE)

  if(_parent_folder STREQUAL "msg")
    list(APPEND _generated_msg_objc_files
      "${_output_path}/${_parent_folder}/${_module_name}.h"
    )

    foreach(_typesupport_impl ${_typesupport_impls})
      list_append_unique(_generated_msg_objc_ts_files
        "${_output_path}/${_parent_folder}/${_module_name}_s.ep.${_typesupport_impl}.m"
      )

      list_append_unique(_generated_objc_ts_files_${_typesupport_impl}
        "${_output_path}/${_parent_folder}/${_module_name}_s.ep.${_typesupport_impl}.m"
      )

      list(APPEND _type_support_by_generated_msg_cpp_files "${_typesupport_impl}")
    endforeach()
  elseif(_parent_folder STREQUAL "srv")
    list(APPEND _generated_srv_objc_files
      "${_output_path}/${_parent_folder}/${_module_name}.h"
    )

    foreach(_typesupport_impl ${_typesupport_impls})
      list_append_unique(_generated_srv_objc_ts_files
        "${_output_path}/${_parent_folder}/${_module_name}_s.ep.${_typesupport_impl}.m"
      )


      list_append_unique(_generated_objc_ts_files_${_typesupport_impl}
        "${_output_path}/${_parent_folder}/${_module_name}_s.ep.${_typesupport_impl}.m"
      )

      list(APPEND _type_support_by_generated_srv_cpp_files "${_typesupport_impl}")
    endforeach()
  else()
    message(FATAL_ERROR "Interface file with unknown parent folder: ${_idl_file}")
  endif()
endforeach()

set(_dependency_files "")
set(_dependencies "")
foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
  foreach(_idl_file ${${_pkg_name}_INTERFACE_FILES})
    set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
    normalize_path(_abs_idl_file "${_abs_idl_file}")
    list(APPEND _dependency_files "${_abs_idl_file}")
    list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
  endforeach()
endforeach()

set(target_dependencies
  "${rosidl_generator_objc_BIN}"
  ${rosidl_generator_objc_GENERATOR_FILES}
  "${rosidl_generator_objc_TEMPLATE_DIR}/msg.h.template"
  "${rosidl_generator_objc_TEMPLATE_DIR}/srv.h.template"
  "${rosidl_generator_objc_TEMPLATE_DIR}/msg.m.template"
  "${rosidl_generator_objc_TEMPLATE_DIR}/srv.m.template"
  ${rosidl_generate_interfaces_IDL_FILES}
  ${_dependency_files})
foreach(dep ${target_dependencies})
  if(NOT EXISTS "${dep}")
    message(FATAL_ERROR "Target dependency '${dep}' does not exist")
  endif()
endforeach()

set(generator_arguments_file "${CMAKE_BINARY_DIR}/rosidl_generator_objc__arguments.json")
rosidl_write_generator_arguments(
  "${generator_arguments_file}"
  PACKAGE_NAME "${PROJECT_NAME}"
  ROS_INTERFACE_FILES "${rosidl_generate_interfaces_IDL_FILES}"
  ROS_INTERFACE_DEPENDENCIES "${_dependencies}"
  OUTPUT_DIR "${_output_path}"
  TEMPLATE_DIR "${rosidl_generator_objc_TEMPLATE_DIR}"
  TARGET_DEPENDENCIES ${target_dependencies}
)

file(MAKE_DIRECTORY "${_output_path}")

set(_generated_extension_files "")
set(_extension_dependencies "")
set(_target_suffix "__objc")

set_property(
  SOURCE
  ${_generated_msg_objc_files} ${_generated_msg_objc_ts_files} ${_generated_srv_objc_files} ${_generated_srv_objc_ts_files}
  PROPERTY GENERATED 1)

add_custom_command(
  OUTPUT ${_generated_msg_objc_files} ${_generated_msg_objc_ts_files} ${_generated_srv_objc_files} ${_generated_srv_objc_ts_files}
  COMMAND ${PYTHON_EXECUTABLE} ${rosidl_generator_objc_BIN}
  --generator-arguments-file "${generator_arguments_file}"
  --typesupport-impl "${_typesupport_impl}"
  --typesupport-impls "${_typesupport_impls}"
  DEPENDS ${target_dependencies}
  COMMENT "Generating Objective C code for ROS interfaces"
  VERBATIM
)

if(TARGET ${rosidl_generate_interfaces_TARGET}${_target_suffix})
  message(WARNING "Custom target ${rosidl_generate_interfaces_TARGET}${_target_suffix} already exists")
else()
  add_custom_target(
    ${rosidl_generate_interfaces_TARGET}${_target_suffix}
    DEPENDS
    ${_generated_msg_objc_files}
    ${_generated_msg_objc_ts_files}
    ${_generated_srv_objc_files}
    ${_generated_srv_objc_ts_files}
  )
endif()

macro(set_properties _build_type)
  set_target_properties(${_library_name} PROPERTIES
    COMPILE_FLAGS "${_extension_compile_flags}"
    LIBRARY_OUTPUT_DIRECTORY${_build_type} ${_output_path}/${_parent_folder}
    RUNTIME_OUTPUT_DIRECTORY${_build_type} ${_output_path}/${_parent_folder}
  )
endmacro()


list(FIND _typesupport_impls "rosidl_typesupport_c" _typesupport_c_idx)
list(LENGTH _typesupport_impls _typesupport_impls_length)
if(_typesupport_impls_length EQUAL 2)
  if(NOT _typesupport_impls_length EQUAL -1)
    list(REMOVE_AT _typesupport_impls ${_typesupport_c_idx})
    # Small optimization to only build the direct typesupport implementation
    # and bypass the meta one if there is only one actual typesupport needed
  endif()
endif()

foreach(_typesupport_impl ${_typesupport_impls})
  find_package(${_typesupport_impl} REQUIRED)

  set(_objcext_suffix "__objcext")
  set(_library_name "ROS_${PROJECT_NAME}__${_typesupport_impl}")

  add_library(${_library_name}
    ${_generated_objc_ts_files_${_typesupport_impl}}
  )

  set(_extension_compile_flags "-Wall -Wextra ${OBJC_FLAGS}")

  set_properties("")
  set_properties("_DEBUG")
  set_properties("_MINSIZEREL")
  set_properties("_RELEASE")
  set_properties("_RELWITHDEBINFO")

  add_dependencies(
    ${_library_name}
    ${rosidl_generate_interfaces_TARGET}${_target_suffix}
    ${rosidl_generate_interfaces_TARGET}__rosidl_typesupport_c
  )

  target_link_libraries(
    ${_library_name}
    ${PROJECT_NAME}__${_typesupport_impl}
    ${OBJC_LIBRARIES}
  )

  rosidl_target_interfaces(${_library_name}
    ${PROJECT_NAME} rosidl_typesupport_c)
  target_include_directories(${_library_name}
    PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_c
    ${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_objc
    ${JNI_INCLUDE_DIRS}
  )
  ament_target_dependencies(${_library_name}
    "rosidl_generator_c"
    "rosidl_generator_objc"
    "rosidl_typesupport_c"
    "rosidl_typesupport_interface"
  )
  foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
    ament_target_dependencies(${_library_name}
      ${_pkg_name}
    )
  endforeach()
  add_dependencies(${_library_name}
    ${rosidl_generate_interfaces_TARGET}__${_typesupport_impl}
  )

  list(APPEND _extension_dependencies ${_library_name})

  if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
    install(TARGETS ${_library_name}
      ARCHIVE DESTINATION lib
      LIBRARY DESTINATION lib
    )
  endif()

endforeach()

# TODO(esteve): move this to its own ament_export_objc_libraries
if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
  if(_typesupport_impls MATCHES ";")
    ament_export_libraries("ROS_${PROJECT_NAME}__rosidl_typesupport_c")
  else()
    ament_export_libraries("ROS_${PROJECT_NAME}__${_typesupport_impls}")
  endif()
endif()

add_dependencies("${PROJECT_NAME}" "${rosidl_generate_interfaces_TARGET}${_target_suffix}")

if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
  set(_install_jar_dir "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")
  if(NOT {_generated_msg_objc_files STREQUAL "")
    install(
      FILES ${_generated_msg_objc_files}
      DESTINATION "include/ROS_${PROJECT_NAME}/msg"
    )
  endif()

  if(NOT {_generated_srv_objc_files STREQUAL "")
    install(
      FILES ${_generated_srv_objc_files}
      DESTINATION "include/ROS_${PROJECT_NAME}/srv"
    )
  endif()

  ament_export_include_directories(include)
endif()
