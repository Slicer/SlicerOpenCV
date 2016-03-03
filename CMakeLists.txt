cmake_minimum_required(VERSION 3.0.1)

project(SlicerOpenCV)

#-----------------------------------------------------------------------------
# Extension meta-information
set(EXTENSION_HOMEPAGE "http://slicer.org/slicerWiki/index.php/Documentation/Nightly/Extensions/SlicerOpenCV")
set(EXTENSION_CATEGORY "Libraries")
set(EXTENSION_CONTRIBUTORS "Nicole Aucoin (BWH), Andrey Fedorov (BWH), Jean-Christophe Fillion-Robin (Kitware)")
set(EXTENSION_DESCRIPTION "This extension provides a wrapper around OpenCV libraries")
set(EXTENSION_ICONURL "https://github.com/SBU-BMI/SlicerOpenCV/blob/master/SlicerOpenCV.png")
set(EXTENSION_SCREENSHOTURLS "")
set(EXTENSION_BUILD_SUBDIRECTORY inner-build)

set(SUPERBUILD_TOPLEVEL_PROJECT inner)

#-----------------------------------------------------------------------------
# Extension dependencies
find_package(Slicer REQUIRED)
include(${Slicer_USE_FILE})
mark_as_superbuild(Slicer_DIR)

find_package(Git REQUIRED)
mark_as_superbuild(GIT_EXECUTABLE)

message(STATUS "${PROJECT_NAME}: PYTHON_EXECUTABLE = ${PYTHON_EXECUTABLE}")

#-----------------------------------------------------------------------------
option(${EXTENSION_NAME}_SUPERBUILD "Build ${EXTENSION_NAME} and the projects it depends on." ON)
mark_as_advanced(${EXTENSION_NAME}_SUPERBUILD)
if(${EXTENSION_NAME}_SUPERBUILD)
  include("${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild.cmake")
  return()
endif()

#-----------------------------------------------------------------------------
# Clear ${PROJECT_NAME}Targets.cmake
file(WRITE ${CMAKE_BINARY_DIR}/${Slicer_SHARE_DIR}/${PROJECT_NAME}Targets.cmake "")

#-----------------------------------------------------------------------------
# Extension modules
# Slicer wrapper around the library
add_subdirectory(OpenCV)
## NEXT_MODULE

#-----------------------------------------------------------------------------
set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${CMAKE_BINARY_DIR};${EXTENSION_NAME};ALL;/")
set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${ITKVideoBridgeOpenCV_DIR};ITKVideoBridgeOpenCV;RuntimeLibraries;/")
include(${Slicer_EXTENSION_CPACK})

#-----------------------------------------------------------------------------
if(NOT Slicer_SOURCE_DIR)
  # Configure 'SlicerOpenCVConfig.cmake'
  include(CMakePackageConfigHelpers)

  message("OpenCV_DIR:${OpenCV_DIR}")
  # For a build tree
  set(SHARE_DIR_CONFIG ${CMAKE_BINARY_DIR}/${Slicer_SHARE_DIR})
  set(OpenCV_DIR_CONFIG ${OpenCV_DIR})
  set(${PROJECT_NAME}_CONFIG_CODE "####### Expanded from \@SlicerOpenCV_CONFIG_CODE\@ #######\n")
  set(${PROJECT_NAME}_CONFIG_CODE "${${PROJECT_NAME}_CONFIG_CODE}##################################################")
  set(_config ${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake)
  configure_package_config_file(
      CMake/${PROJECT_NAME}Config.cmake.in
      ${_config}
      INSTALL_DESTINATION ${CMAKE_BINARY_DIR}
      PATH_VARS SHARE_DIR_CONFIG OpenCV_DIR_CONFIG
      NO_CHECK_REQUIRED_COMPONENTS_MACRO
  )
endif()
