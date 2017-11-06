# Copyright 2017 Esteve Fernandez <esteve@apache.org>
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

if(APPLE)
  set(OBJC_LIBRARIES "-framework Foundation")
  set(OBJC_FLAGS "")
elseif(UNIX)
  find_program(GNUSTEP_CONFIG gnustep-config)
  message("Found gnustep-config at: ${GNUSTEP_CONFIG}")
  if(NOT DEFINED GNUSTEP_CONFIG)
    message(FATAL_ERROR "Error: gnustep-config not found. exiting")
  endif()
  execute_process(COMMAND ${GNUSTEP_CONFIG} --base-libs OUTPUT_VARIABLE OBJC_LIBRARIES OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND ${GNUSTEP_CONFIG} --objc-flags OUTPUT_VARIABLE OBJC_FLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE "-g -O2" "" OBJC_FLAGS ${OBJC_FLAGS})
  set(OBJC_FLAGS "${OBJC_FLAGS} -fblocks")
  mark_as_advanced(GNUSTEP_CONFIG)
endif()

function(add_objc_executable TARGET_NAME)
  add_executable(${TARGET_NAME} ${ARGN})
  set_target_properties(${TARGET_NAME} PROPERTIES
    LINKER_LANGUAGE CXX
    COMPILE_FLAGS "${OBJC_FLAGS}")
  target_link_libraries(${TARGET_NAME} ${OBJC_LIBRARIES})
endfunction()