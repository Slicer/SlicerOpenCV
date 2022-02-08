cmake_minimum_required(VERSION 3.0.1)

project(SlicerOpenCV)

#-----------------------------------------------------------------------------
# Extension meta-information
set(EXTENSION_HOMEPAGE "http://slicer.org/slicerWiki/index.php/Documentation/Nightly/Extensions/SlicerOpenCV")
set(EXTENSION_CATEGORY "Libraries")
set(EXTENSION_CONTRIBUTORS "Nicole Aucoin (BWH), Andrey Fedorov (BWH), Jean-Christophe Fillion-Robin (Kitware)")
set(EXTENSION_DESCRIPTION "This extension provides a wrapper around OpenCV libraries")
set(EXTENSION_ICONURL "https://raw.githubusercontent.com/SBU-BMI/SlicerOpenCV/master/SlicerOpenCV.png")
set(EXTENSION_SCREENSHOTURLS "")
set(EXTENSION_BUILD_SUBDIRECTORY inner-build)

set(SUPERBUILD_TOPLEVEL_PROJECT inner)

#-----------------------------------------------------------------------------
# Extension dependencies
find_package(Slicer REQUIRED)
include(${Slicer_USE_FILE})
mark_as_superbuild(Slicer_DIR)

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
add_subdirectory(SlicerOpenCV)
## NEXT_MODULE

#-----------------------------------------------------------------------------
set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${CMAKE_BINARY_DIR};${EXTENSION_NAME};ALL;/")
set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${ITKVideoBridgeOpenCV_DIR};ITKVideoBridgeOpenCV;RuntimeLibraries;/")
set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${OpenCV_BUILD_DIR};python;python;/")
MESSAGE(STATUS "CPACK_INSTALL_CMAKE_PROJECTS = ${CPACK_INSTALL_CMAKE_PROJECTS}")

include(${Slicer_EXTENSION_GENERATE_CONFIG})
include(${Slicer_EXTENSION_CPACK})

