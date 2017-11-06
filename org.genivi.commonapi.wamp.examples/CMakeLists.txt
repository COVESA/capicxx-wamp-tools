# Copyright (C) 2017 itemis AG
# Author: Klaus Birken (klaus.birken@itemis.de)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

cmake_minimum_required(VERSION 2.8)

set(PRJ10_NAME Example10)
set(PRJ77_NAME Example77)

set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -O0 -std=c++0x -D_GLIBCXX_USE_NANOSLEEP -pthread")

message(STATUS "Compiler options: ${CMAKE_CXX_FLAGS}") 

if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
       "Choose the type of build, options are: Debug Release." FORCE)
endif(NOT CMAKE_BUILD_TYPE)
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

OPTION(USE_INSTALLED_COMMONAPI "Set to OFF to use the local (build tree) version of CommonAPI" ON)
message(STATUS "USE_INSTALLED_COMMONAPI is set to value: ${USE_INSTALLED_COMMONAPI}")

if ("${USE_INSTALLED_COMMONAPI}" STREQUAL "ON")
    FIND_PACKAGE(CommonAPI REQUIRED CONFIG NO_CMAKE_PACKAGE_REGISTRY)
    FIND_PACKAGE(CommonAPI-WAMP REQUIRED CONFIG NO_CMAKE_PACKAGE_REGISTRY)
else()
    FIND_PACKAGE(CommonAPI REQUIRED CONFIG NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
    FIND_PACKAGE(CommonAPI-WAMP REQUIRED CONFIG NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
endif()

message(STATUS "CommonAPI_CONSIDERED_CONFIGS: ${CommonAPI_CONSIDERED_CONFIGS}")
message(STATUS "COMMONAPI_INCLUDE_DIRS: ${COMMONAPI_INCLUDE_DIRS}")
message(STATUS "CommonAPI-WAMP_CONSIDERED_CONFIGS: ${CommonAPI-WAMP_CONSIDERED_CONFIGS}")
message(STATUS "COMMONAPI_WAMP_INCLUDE_DIRS: ${COMMONAPI_WAMP_INCLUDE_DIRS}")

# CommonAPI
include(FindPkgConfig)
#pkg_check_modules (DBUS "dbus-1 >= 1.4")

# Source Files
set(PRJ10_SRC_PATH src/example10/server)
set(PRJ77_SRC_PATH src/example77/server)
set(PRJ10_SRC_GEN_PATH src-gen/v0/testcases/example10)
set(PRJ77_SRC_GEN_PATH src-gen/v0/testcases/example77)

#set(PRJ_NAME_CLIENT ${PRJ_NAME}Client)
set(PRJ10_NAME_SERVICE ${PRJ10_NAME}Service)
set(PRJ77_NAME_SERVICE ${PRJ77_NAME}Service)

FILE(GLOB PRJ10_WAMP_LIB_SRCS ${PRJ10_SRC_GEN_PATH}/*Wamp*.cpp)
FILE(GLOB PRJ77_WAMP_LIB_SRCS ${PRJ77_SRC_GEN_PATH}/*Wamp*.cpp)

FILE(GLOB PRJ10_STUB_GEN_SRCS ${PRJ10_SRC_GEN_PATH}/*StubDefault.cpp)
FILE(GLOB PRJ77_STUB_GEN_SRCS ${PRJ77_SRC_GEN_PATH}/*StubDefault.cpp)
FILE(GLOB PRJ10_STUB_IMPL_SRCS ${PRJ10_SRC_PATH}/*Stub*.cpp)
FILE(GLOB PRJ77_STUB_IMPL_SRCS ${PRJ77_SRC_PATH}/*Stub*.cpp)

#set(PRJ_CLIENT_SRCS ${PRJ_SRC_PATH}/${PRJ_NAME_CLIENT}.cpp)
set(PRJ10_SERVICE_SRCS ${PRJ10_SRC_PATH}/${PRJ10_NAME_SERVICE}.cpp ${PRJ10_STUB_GEN_SRCS} ${PRJ10_STUB_IMPL_SRCS})
set(PRJ77_SERVICE_SRCS ${PRJ77_SRC_PATH}/${PRJ77_NAME_SERVICE}.cpp ${PRJ77_STUB_GEN_SRCS} ${PRJ77_STUB_IMPL_SRCS})

# Paths
#OPTION(USE_INSTALLED_WAMP "Set to OFF to use the local (patched) version of wamp" ON)
#message(STATUS "USE_INSTALLED_WAMP is set to value: ${USE_INSTALLED_WAMP}")

include_directories(
    src-gen
    ${COMMONAPI_INCLUDE_DIRS}
    ${COMMONAPI_WAMP_INCLUDE_DIRS}
    ${WAMP_INCLUDE_DIRS}
)

#if ("${USE_INSTALLED_WAMP}" STREQUAL "ON")
link_directories(
    ${COMMONAPI_LIBDIR}
    ${COMMONAPI_WAMP_LIBDIR}
    ${WAMP_LIBDIR}
)
#else()
#link_directories(
#    ${COMMONAPI_LIBDIR}
#    ${COMMONAPI_WAMP_LIBDIR}
#    ${WAMP_INCLUDE_DIRS}/wamps/.libs
#)
#endif()

#set(LINK_LIBRARIES -Wl,--no-as-needed -Wl,--as-needed CommonAPI -lboost_thread)
set(LINK_LIBRARIES -Wl,--no-as-needed -Wl,--as-needed CommonAPI)

# Build Client
#add_executable(${PRJ_NAME_CLIENT} ${PRJ_CLIENT_SRCS})
#target_link_libraries(${PRJ_NAME_CLIENT} ${LINK_LIBRARIES})

# Build service
add_executable(${PRJ10_NAME_SERVICE} ${PRJ10_SERVICE_SRCS})
target_link_libraries(${PRJ10_NAME_SERVICE} ${LINK_LIBRARIES})
add_executable(${PRJ77_NAME_SERVICE} ${PRJ77_SERVICE_SRCS})
target_link_libraries(${PRJ77_NAME_SERVICE} ${LINK_LIBRARIES})

# Build gluecode.so
add_library (${PRJ10_NAME}-wamp SHARED ${PRJ10_WAMP_LIB_SRCS})
target_link_libraries(${PRJ10_NAME}-wamp CommonAPI-WAMP ${WAMP_LIBRARIES})
add_library (${PRJ77_NAME}-wamp SHARED ${PRJ77_WAMP_LIB_SRCS})
target_link_libraries(${PRJ77_NAME}-wamp CommonAPI-WAMP ${WAMP_LIBRARIES})
