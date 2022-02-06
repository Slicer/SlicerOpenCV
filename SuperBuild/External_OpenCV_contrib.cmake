set(proj OpenCV_contrib)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  unset(OpenCV_DIR CACHE)
  find_package(OpenCV 4.1 REQUIRED)
  if(NOT OPENCV_ARUCO_FOUND)
    message(FATAL_ERROR System OpenCV not built with contrib modules)
  endif()
endif()

# Sanity checks
if(DEFINED OpenCV_DIR AND NOT EXISTS ${OpenCV_DIR})
  message(FATAL_ERROR "OpenCV_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED OpenCV_DIR AND NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  if(NOT DEFINED git_protocol)
    set(git_protocol "git")
  endif()

  ExternalProject_SetIfNotDefined(
    ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
    https://github.com/opencv/opencv_contrib.git
    QUIET
    )

  ExternalProject_SetIfNotDefined(
    ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
    4.5.5
    QUIET
    )

  set(${proj}_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj})

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
    GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    #--Configure step-------------
    CONFIGURE_COMMAND "" # don't configure
    #--Build step-----------------
    BUILD_COMMAND "" # don't build
    #--Install step-----------------
    INSTALL_COMMAND "" # don't install
    #--Dependencies-----------------
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )

  ExternalProject_GenerateProjectDescription_Step(${proj})
else()
  # The project is provided using OpenCV_DIR, nevertheless since other projects
  # may depend on OpenCV, let's add an 'empty' one
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
endif()

# Set this source directory for the upper level cmake file
ExternalProject_Message(${proj} "opencv_contrib_SOURCE_DIR = ${${proj}_SOURCE_DIR}")
mark_as_superbuild(${proj}_SOURCE_DIR)
