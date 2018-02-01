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
      URL "https://github.com/Itseez/opencv/archive/3.3.1.tar.gz"
      URL_MD5 "b1ed9aea030bb5bd9df28524d97de84c"
      )
  endif()
  set(${proj}_INSTALL_DIR ${CMAKE_BINARY_DIR}/${proj}-install)

  if(APPLE)
    # Workaround for OpenCV 3.2+ and OSX clang compiler issues
    list(APPEND ADDITIONAL_OPENCV_ARGS -DBUILD_PROTOBUF:BOOL=OFF)
  endif()

  ExternalProject_Message(${proj} "${proj}_SOURCE_DIR:${${proj}_SOURCE_DIR}")
  ExternalProject_Message(${proj} "Slicer_INSTALL_THIRDPARTY_LIB_DIR = ${Slicer_INSTALL_THIRDPARTY_LIB_DIR}")

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
      # Uses runtime compatible with ITK. See issue #26
      -DBUILD_WITH_STATIC_CRT:BOOL=OFF
      -DOPENCV_MANGLE_PREFIX:STRING=slicer_opencv_
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_DOCS:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_PERF_TESTS:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_WITH_DEBUG_INFO:BOOL=OFF
      # Enable modules
      -DBUILD_opencv_core:BOOL=ON
      -DBUILD_opencv_highgui:BOOL=ON
      -DBUILD_opencv_imgcodecs:BOOL=ON
      -DBUILD_opencv_imgproc:BOOL=ON
      -DBUILD_opencv_ml:BOOL=ON
      -DBUILD_opencv_objdetect:BOOL=ON
      -DBUILD_opencv_photo:BOOL=ON
      -DBUILD_opencv_video:BOOL=ON
      -DBUILD_opencv_videoio:BOOL=ON
      # Enable modules required by the fact ITK calls 'find_package(OpenCV)' without specifying components.
      -DBUILD_opencv_calib3d:BOOL=ON
      -DBUILD_opencv_features2d:BOOL=ON
      -DBUILD_opencv_flann:BOOL=ON
      -DBUILD_opencv_shape:BOOL=ON
      -DBUILD_opencv_stitching:BOOL=ON
      -DBUILD_opencv_superres:BOOL=ON
      -DBUILD_opencv_videostab:BOOL=ON
      # Disable unused modules
      -DBUILD_opencv_apps:BOOL=OFF
      -DBUILD_opencv_ts:BOOL=OFF
      -DBUILD_opencv_world:BOOL=OFF
      # Disable VTK: not used, and is causing problems
      -DWITH_VTK:BOOL=OFF
      # Disable OpenCL: Initially disabled because of build errors on MacOSX 10.6 (See #17)
      -DWITH_OPENCL:BOOL=OFF
      # Disable find_package(Java) so that java wrapping is not done
      -DCMAKE_DISABLE_FIND_PACKAGE_JAVA:BOOL=ON
      # Add Python wrapping, use Slicer's python
      -DBUILD_opencv_python2:BOOL=ON
      -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
      -DINSTALL_PYTHON_EXAMPLES:BOOL=OFF
      # install the python package in the third party lib dir
      -DPYTHON2_PACKAGES_PATH:PATH=${PYTHON_SITE_PACKAGES_SUBDIR}
      ${ADDITIONAL_OPENCV_ARGS}
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )
  set(OpenCV_DIR ${${proj}_INSTALL_DIR})
  if(UNIX)
    set(OpenCV_DIR ${${proj}_INSTALL_DIR}/share/OpenCV)
  endif()
else()
  # The project is provided using OpenCV_DIR, nevertheless since other projects
  # may depend on OpenCV, let's add an 'empty' one
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
endif()

ExternalProject_Message(${proj} "OpenCV_DIR:${OpenCV_DIR}")
mark_as_superbuild(OpenCV_DIR:PATH)

# Set the python wrapped library path for the extension cmake file
set(${proj}_PYTHON_LIB_DIR ${CMAKE_BINARY_DIR}/${proj}-build/lib)
ExternalProject_Message(${proj} "OpenCV_PYTHON_LIB_DIR = ${${proj}_PYTHON_LIB_DIR}")
mark_as_superbuild(${proj}_PYTHON_LIB_DIR:PATH)

# Set this build directory for the upper level cmake file
set(${proj}_BUILD_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
ExternalProject_Message(${proj} "OpenCV_BUILD_DIR = ${${proj}_BUILD_DIR}")
mark_as_superbuild(${proj}_BUILD_DIR)
