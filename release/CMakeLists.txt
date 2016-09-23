cmake_minimum_required(VERSION 2.8.7)

# Allow use of project folders for IDEs like Visual Studio, so we
# could organize projects into relevant folders: "cpr", "tests" & "external (libraries)".
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMake")

set(ANDROID_STL_FLAGS)

project(cpr)

if(IOS)
  message(STATUS "Building for curl for IOS")
  set(IOS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../build_ios")

  set(BUILD_CPR_TESTS OFF CACHE BOOL "Don't build cpr tests")
  message(STATUS "building for IOS")

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -Wno-return-type-c-linkage -Wno-unneeded-internal-declaration")
  set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
  set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-strict-aliasing")

  set(ZLIB_INCLUDE_DIRS "${CMAKE_IOS_SDK_ROOT}/usr/include")
  set(ZLIB_LIBRARIES "${CMAKE_IOS_SDK_ROOT}/usr/lib/libz.tbd")

  message(STATUS "ZLIB_LIBRARIES ${ZLIB_INCLUDE_DIRS}")
  message(STATUS "ZLIB_INCLUDE_DIRS ${ZLIB_LIBRARIES}")

  find_library(SECURITY Security "/")
  find_library(COREFOUNDATION CoreFoundation "/")
  message(STATUS "found xcode sucurity framework ${SECURITY}")
  set(EXTRALINKS ${COREFOUNDATION} ${SECURITY})
elseif(ANDROID)
  message(STATUS "Building for android")

  set(ANDROID_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../build_android")
  set(BUILD_CPR_TESTS OFF CACHE BOOL "Don't build cpr tests")

  if(ARMEABI_V7A)
    message(STATUS "Building for curl for android ARM")
    set(CURL_INCLUDE_DIRS "${ANDROID_SOURCE_DIR}/curl/include")
    set(CURL_LIBRARIES "${ANDROID_SOURCE_DIR}/curl/armeabi-v7a/libcurl.a")
  else()
    message(STATUS "Building curl for android x86")
    set(CURL_INCLUDE_DIRS "${ANDROID_SOURCE_DIR}/curl/include")
    set(CURL_LIBRARIES "${ANDROID_SOURCE_DIR}/curl/x86/libcurl.a")
  endif()

  message(STATUS "CURL_INCLUDE_DIRS ${CURL_INCLUDE_DIRS}")
  message(STATUS "CURL_LIBRARIES ${CURL_LIBRARIES}")

  if(ARMEABI_V7A)
    message(-- "Building for ARM")
    set(LIBCXX_STL "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi-v7a/thumb/libgnustl_static.a")
  else()
    set(LIBCXX_STL "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.8/libs/x86/libgnustl_static.a")
  endif()

  find_package(ZLIB)

  option(BUILD_SHARED_LIBS "Build shared Libraries." OFF)
  set(BUILD_SAMPLES OFF)

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-strict-aliasing")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-pedantic")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-attributes -Wno-pointer-arith")
  include_directories(
    "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.8/include"
    "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi-v7a/include"
    "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.8/include/backward"
  )
else()
  message(STATUS "Building for curl for mac")
  find_package(CURL)
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Binaries)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Binaries)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Binaries)

if(NOT ${CMAKE_VERSION} LESS 3.2)
    set(CMAKE_CXX_STANDARD 11)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
else()
    message(STATUS "Checking compiler flags for C++11 support.")
    # Set C++11 support flags for various compilers
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag("-std=c++11" COMPILER_SUPPORTS_CXX11)
    check_cxx_compiler_flag("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
    if(COMPILER_SUPPORTS_CXX11)
        message(STATUS "C++11 is supported.")
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
        endif()
    elseif(COMPILER_SUPPORTS_CXX0X)
        message(STATUS "C++0x is supported.")
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -stdlib=libc++")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
        endif()
    else()
        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
    endif()
endif()

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)

set(CPR_LIBRARIES cpr CACHE INTERNAL "")
set(CPR_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include CACHE INTERNAL "")

macro(cpr_option OPTION_NAME OPTION_TEXT OPTION_DEFAULT)
    option(${OPTION_NAME} ${OPTION_TEXT} ${OPTION_DEFAULT})
    if(DEFINED ENV{${OPTION_NAME}})
        # Allow setting the option through an environment variable
        set(${OPTION_NAME} $ENV{${OPTION_NAME}})
    endif()
    if(${OPTION_NAME})
        add_definitions(-D${OPTION_NAME})
    endif()
    message(STATUS "  ${OPTION_NAME}: ${${OPTION_NAME}}")
endmacro()

message(STATUS "C++ Requests CMake Options")
message(STATUS "=======================================================")
cpr_option(USE_SYSTEM_CURL
    "If ON, this project will look in the system paths for an installed curl library" OFF)
cpr_option(BUILD_CPR_TESTS "Set to ON to build cpr tests." ON)
cpr_option(INSECURE_CURL "Set to ON to disable verification of SSL certificates." OFF)
cpr_option(GENERATE_COVERAGE "Set to ON to generate coverage reports." OFF)
cpr_option(USE_SYSTEM_GTEST
    "If ON, this project will look in the system paths for an installed gtest library" OFF)
cpr_option(CMAKE_USE_OPENSSL "Use OpenSSL code. Experimental" ON)
message(STATUS "=======================================================")

if(BUILD_CPR_TESTS)
  enable_testing()
endif()

add_subdirectory(opt)
add_subdirectory(cpr)

if(BUILD_CPR_TESTS)
  add_subdirectory(test)
endif()
