cmake_minimum_required(VERSION 3.0.1)

project(SlicerOpenCV)

#-----------------------------------------------------------------------------
# Extension meta-information
set(EXTENSION_HOMEPAGE "http://slicer.org/slicerWiki/index.php/Documentation/Nightly/Extensions/SlicerOpenCV")
set(EXTENSION_CATEGORY "Libraries")
set(EXTENSION_CONTRIBUTORS "Nicole Aucoin (BWH)")
set(EXTENSION_DESCRIPTION "This extension provides a wrapper around OpenCV libraries")
set(EXTENSION_ICONURL "http://www.example.com/Slicer/Extensions/SlicerOpenCV.png")
set(EXTENSION_SCREENSHOTURLS "")

#-----------------------------------------------------------------------------
# Extension dependencies
find_package(Slicer REQUIRED)
message(STATUS "including ${Slicer_USE_FILE}")
include(${Slicer_USE_FILE})

#-----------------------------------------------------------------------------
# Compile OpenCV as an external project if not using the system one
include(ExternalProject)

set(proj opencv)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  unset(opencv_DIR CACHE)
  find_package(OPENCV REQUIRED)
  set(OPENCV_INCLUDE_DIR ${OPENCV_INCLUDE_DIRS})
  set(OPENCV_LIBRARY ${OPENCV_LIBRARIES})
endif()

# Sanity checks
if(DEFINED opencv_DIR AND NOT EXISTS ${opencv_DIR})
  message(FATAL_ERROR "opencv_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED opencv_DIR AND NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  if(NOT DEFINED git_protocol)
    set(git_protocol "git")
  endif()

  # check out to the binary dir to keep the git checkout clean
  set(EP_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}-source)
  set(EP_BINARY_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
  set(EP_INSTALL_DIR ${CMAKE_BINARY_DIR}/${Slicer_QTLOADABLEMODULES_LIB_DIR})

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${git_protocol}://github.com/itseez/opencv.git"
    # for version 3.0.0
    GIT_TAG "c12243cf4fccf5df7b0270a32883986b373dca7b"
    SOURCE_DIR ${EP_SOURCE_DIR}
    BINARY_DIR ${EP_BINARY_DIR}
    INSTALL_DIR ${EP_INSTALL_DIR}
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DOPENCV_MANGLE_PREFIX:STRING=slicer_opencv_
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_TESTING:BOOL=ON
      -DBUILD_EXAMPLES:BOOL=ON
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )

  set(opencv_DIR ${EP_INSTALL_DIR})
  set(OPENCV_ROOT ${opencv_DIR})
  set(OPENCV_INCLUDE_DIR ${opencv_DIR}/include)
  if(WIN32)
    set(OPENCV_LIBRARY ${opencv_DIR}/opencv.lib)
  else()
    set(OPENCV_LIBRARY ${opencv_DIR}/libopencv.a)
  endif()
else()
  # The project is provided using opencv_DIR, nevertheless since other projects
  # may depend on opencv, let's add an 'empty' one
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
endif()

ExternalProject_Message(${proj} "OPENCV_INCLUDE_DIR:${OPENCV_INCLUDE_DIR}")
ExternalProject_Message(${proj} "OPENCV_LIBRARY:${OPENCV_LIBRARY}")
if(OPENCV_ROOT)
  ExternalProject_Message(${proj} "OPENCV_ROOT:${OPENCV_ROOT}")
endif()

#-----------------------------------------------------------------------------
# Build the ITK OpenCV bridge, pointing it to Slicer's ITK and this build
# of OpenCV
set(bridgeproj bridgeopencv)

# Dependencies
set(${bridgeproj}_DEPENDENCIES "")
ExternalProject_Include_Dependencies(${bridgeproj} PROJECT_VAR bridgeproj DEPENDS_VAR ${bridgeproj}_DEPENDENCIES)

# don't allow using the system ITK, use the Slicer one
set(BRIDGE_BINARY_DIR ${CMAKE_BINARY_DIR}/${bridgeproj}-build)
set(BRIDGE_INSTALL_DIR ${CMAKE_BINARY_DIR}/${Slicer_QTLOADABLEMODULES_LIB_DIR})

set(ITK_SOURCE_DIR ${ITK_DIR}/../ITKv4)
set(ITK_BRIDGE_SOURCE_DIR ${ITK_SOURCE_DIR}/Modules/Video/BridgeOpenCV)
message(STATUS "ITK source dir set to ${ITK_SOURCE_DIR}")
message(STATUS "ITK source dir set to ${ITK_BRIDGE_SOURCE_DIR}")
mark_as_superbuild(
  VARS ITK_BRIDGE_SOURCE_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
# let cmake find ITKExternal
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${ITK_SOURCE_DIR}/CMake")

ExternalProject_Add(${bridgeproj}
  ${${bridgeproj}_EP_ARGS}
  DEPENDS ${proj}
  # build from Slicer's ITK into the extension's ITK build dir
  SOURCE_DIR ${ITK_BRIDGE_SOURCE_DIR}
  BINARY_DIR ${BRIDGE_BINARY_DIR}
  INSTALL_DIR ${BRIDGE_INSTALL_DIR}
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    -DCMAKE_BUILD_TYPE:STRING=Debug
    # to find ITKConfig.cmake
    -DITK_DIR:PATH=${ITK_DIR}
    # OpenCV
    -DOpenCV_INCLUDE_DIRS:STRING=${OPENCV_INCLUDE_DIR};${OPENCV_INCLUDE_DIR}/opencv
    -DOpenCV_LIB_DIR:PATH=${opencv_DIR}/lib
    -DOpenCV_DIR:PATH=${opencv_DIR}/share/OpenCV
    -DOpenCV_LIB_DIR_DBG:PATH=${opencv_DIR}/lib
    -DOpenCV_LIB_DIR_OPT:PATH=${opencv_DIR}/lib
    -DOpenCV_LIBS:STRING=opencv_core;opencv_videoio;opencv_imgproc
    -DCMAKE_INSTALL_PREFIX:PATH=${BRIDGE_INSTALL_DIR}
)

#-----------------------------------------------------------------------------
# Extension modules
# Slicer wrapper around the library
add_subdirectory(OpenCV)
## NEXT_MODULE

#-----------------------------------------------------------------------------
include(${Slicer_EXTENSION_CPACK})
