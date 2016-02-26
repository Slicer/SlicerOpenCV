set(proj OpenCV)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  unset(OpenCV_DIR CACHE)
  find_package(OpenCV REQUIRED)
  set(OpenCV_INCLUDE_DIR ${OpenCV_INCLUDE_DIRS})
  set(OpenCV_LIBRARY ${OpenCV_LIBRARIES})
endif()

# Sanity checks
if(DEFINED OpenCV_DIR AND NOT EXISTS ${OpenCV_DIR})
  message(FATAL_ERROR "OpenCV_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED OpenCV_DIR AND NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  if(NOT DEFINED git_protocol)
    set(git_protocol "git")
  endif()

  if(DEFINED ${proj}_SOURCE_DIR)
    list(APPEND ${proj}_EP_ARGS DOWNLOAD_COMMAND "")
  else()
    set(${proj}_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}-source)
    list(APPEND ${proj}_EP_ARGS
      URL "https://github.com/Itseez/opencv/archive/3.0.0.tar.gz"
      URL_MD5 "e6c72f54f7127161b371ef798f34d5c9"
      )
  endif()
  set(${proj}_INSTALL_DIR ${CMAKE_BINARY_DIR}/${proj}-install)

  ExternalProject_Message(${proj} "${proj}_SOURCE_DIR:${${proj}_SOURCE_DIR}")

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${proj}-build
    INSTALL_DIR ${${proj}_INSTALL_DIR}
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DWITH_IPP:BOOL=OFF
      # python settings to use the Slicer one
      -DPYTHON2_EXECUTABLE:PATH=${PYTHON_EXECUTABLE}
      -DOPENCV_MANGLE_PREFIX:STRING=slicer_opencv_
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_TESTING:BOOL=ON
      -DBUILD_EXAMPLES:BOOL=ON
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )

  set(OpenCV_DIR ${${proj}_INSTALL_DIR}/share/OpenCV)
else()
  # The project is provided using OpenCV_DIR, nevertheless since other projects
  # may depend on OpenCV, let's add an 'empty' one
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
endif()

ExternalProject_Message(${proj} "OpenCV_DIR:${OpenCV_DIR}")
mark_as_superbuild(OpenCV_DIR:PATH)
