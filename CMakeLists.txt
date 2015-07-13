cmake_minimum_required(VERSION 3.0.0)

#include("common.cmake")

project(superbuild NONE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}; -std=c++11")

#Introduce some Variables
set(ANDROID_ARCH "arm" 	  CACHE STRING "Android Target Architecture")
set(ANDROID_ABI "armeabi" CACHE STRING "Android ABI")
set(ANDROID_API_VERSION "21" CACHE STRING "Android API Level")
set(ANDROID_TOOLCHAIN "arm-linux-androideabi-4.9" CACHE STRING "Android toolchain")
set(ANDROID_NDK "$ENV{NDK_ROOT}" CACHE PATH "Path to Android NDK")
set(BOOST_VERSION "1.55.0" CACHE STRING "Boost Version to build")

include(setup-superbuild.cmake)

include(setup-project-variables.cmake)

include(external-project-macros.cmake)

install_eigen()
fetch_vtk()
fetch_pcl2()
fetch_boost()
fetch_flann()
### TEST ###

#hunter_add_package(Boost COMPONENTS system filesystem thread date_time iostreams serialization chrono log)
### ########
set(tags)

if(BUILD_ANDROID)
 list(APPEND tags android)
endif()
if(BUILD_IOS_DEVICE)
 list(APPEND tags ios-device)
endif()
if(BUILD_IOS_SIMULATOR)
 list(APPEND tags ios-simulator)
endif()

foreach(tag ${tags})
  crosscompile_vtk(${tag})
  crosscompile_boost(${tag})
  crosscompile_flann(${tag})
  crosscompile_pcl(${tag})
endforeach()

if (BUILD_IOS_DEVICE)
  create_pcl_framework()
endif()
