set(proj OpenCV)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SYSTEM_${proj})
  unset(OpenCV_DIR CACHE)
  find_package(OpenCV 4.5 REQUIRED)
  if(NOT OPENCV_ARUCO_FOUND)
    message(FATAL_ERROR System OpenCV not built with contrib modules)
  endif()
  set(OpenCV_INCLUDE_DIR ${OpenCV_INCLUDE_DIRS})
  set(OpenCV_LIBRARY ${OpenCV_LIBRARIES})
endif()

# Sanity checks
if(DEFINED OpenCV_DIR AND NOT EXISTS ${OpenCV_DIR})
  message(FATAL_ERROR "OpenCV_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED OpenCV_DIR AND NOT ${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SYSTEM_${proj})

  # OpenCV_contrib
  ExternalProject_SetIfNotDefined(
    ${SUPERBUILD_TOPLEVEL_PROJECT}_OpenCV_contrib_GIT_REPOSITORY
    "https://github.com/Slicer/opencv_contrib.git"
    QUIET
    )

  ExternalProject_SetIfNotDefined(
    ${SUPERBUILD_TOPLEVEL_PROJECT}_OpenCV_contrib_GIT_TAG
    "49e8f123ca08e76891856a1ecce491b62d08ba20" # slicer-4.5.5-2021.12.25-49e8f123
    QUIET
    )

  set(OpenCV_contrib_SOURCE_DIR ${CMAKE_BINARY_DIR}/OpenCV_contrib)
  ExternalProject_Message(${proj} "OpenCV_contrib_SOURCE_DIR:${OpenCV_contrib_SOURCE_DIR}")
  ExternalProject_Add(OpenCV_contrib-source
    GIT_REPOSITORY "${${SUPERBUILD_TOPLEVEL_PROJECT}_OpenCV_contrib_GIT_REPOSITORY}"
    GIT_TAG "${${SUPERBUILD_TOPLEVEL_PROJECT}_OpenCV_contrib_GIT_TAG}"
    DOWNLOAD_DIR ${CMAKE_BINARY_DIR}
    SOURCE_DIR ${OpenCV_contrib_SOURCE_DIR}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    )
  list(APPEND ${proj}_DEPENDENCIES
    OpenCV_contrib-source
    )

  # OpenCV
  ExternalProject_SetIfNotDefined(
    ${SUPERBUILD_TOPLEVEL_PROJECT}_${proj}_GIT_REPOSITORY
    https://github.com/Slicer/opencv.git
    QUIET
    )

  ExternalProject_SetIfNotDefined(
    ${SUPERBUILD_TOPLEVEL_PROJECT}_${proj}_GIT_TAG
    "7ab1af39429f208bf0a7affe9683bb509cdda5e9" # slicer-4.5.5-2021.12.25-dad26339a9
    QUIET
    )

  set(${proj}_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj})
  set(${proj}_INSTALL_DIR ${CMAKE_BINARY_DIR}/${proj}-install)

  if(APPLE)
    # Workaround for OpenCV 3.2+ and OSX clang compiler issues
    list(APPEND ADDITIONAL_OPENCV_ARGS -DBUILD_PROTOBUF:BOOL=OFF)
  endif()

  option(SlicerOpenCV_USE_CUDA "Enable or disable the building of CUDA modules" OFF)

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${${SUPERBUILD_TOPLEVEL_PROJECT}_${proj}_GIT_REPOSITORY}"
    GIT_TAG "${${SUPERBUILD_TOPLEVEL_PROJECT}_${proj}_GIT_TAG}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${proj}-build
    INSTALL_DIR ${${proj}_INSTALL_DIR}
    CMAKE_CACHE_ARGS
      # Compiler settings
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=${CMAKE_CXX_STANDARD_REQUIRED}
      -DCMAKE_CXX_EXTENSIONS:BOOL=${CMAKE_CXX_EXTENSIONS}

      # Options
      -DBUILD_WITH_STATIC_CRT:BOOL=OFF # Uses runtime compatible with ITK. See issue #26
      -DOPENCV_MANGLE_PREFIX:STRING=slicer_opencv_
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_DOCS:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_PERF_TESTS:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_WITH_DEBUG_INFO:BOOL=OFF
      -DOPENCV_BIN_INSTALL_PATH:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_BIN_DIR}

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

      # Features
      -DWITH_IPP:BOOL=OFF
      -DWITH_EIGEN:BOOL=OFF
      -DWITH_OPENCL:BOOL=OFF # Initially disabled because of build errors on MacOSX 10.6 (See #17)
      -DCUDA_GENERATION:STRING=${Slicer_CUDA_GENERATION}
      -DWITH_CUDA:BOOL=${SlicerOpenCV_USE_CUDA}
      -DBUILD_JAVA:BOOL=OFF
      -DWITH_GTK:BOOL=OFF
      -DWITH_GTK_2_X:BOOL=OFF
      -DWITH_QT:BOOL=OFF
      -DWITH_WIN32UI:BOOL=OFF

      # Options: Python
      -DOPENCV_SKIP_PYTHON_LOADER:BOOL=ON
      -DINSTALL_PYTHON_EXAMPLES:BOOL=OFF
      -DOPENCV_PYTHON_EXTRA_DEFINITIONS:STRING=CV_RELEASE_PYTHON # Specific to Slicer/opencv fork

      # Dependencies: Python
      # - Options expected by the OpenCV custom CMake function "find_python()"
      #   implemented in "cmake/OpenCVDetectPython.cmake"
      -DPYTHON3_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
      -DPYTHON3_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
      -DPYTHON3_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
      # - Options expected by the FindPythonInterp and FindPythonLibs CMake built-in modules
      #   indirectly used in the OpenCV custom CMake macro "find_host_package"
      #   implemented in "cmake/OpenCVUtils.cmake" and used in "find_python()".
      -DPYTHON_EXECUTABLE:PATH=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}

      # Dependencies: VTK
      -DVTK_DIR:PATH=${VTK_DIR}

      # Dependencies: ZLIB
      -DBUILD_ZLIB:BOOL=OFF
      -DZLIB_ROOT:PATH=${ZLIB_ROOT}
      -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
      -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
      -DCMAKE_POLICY_DEFAULT_CMP0074:STRING=NEW # Explicitly set to NEW to ensure ZLIB_ROOT is not ignored.

      # Dependencies: Media I/O
      -DBUILD_JPEG:BOOL=ON
      -DBUILD_OPENEXR:BOOL=ON
      -DBUILD_PNG:BOOL=ON
      -DBUILD_TIFF:BOOL=ON
      -DBUILD_WEBP:BOOL=ON

      # Dependencies: Media I/O: ZLIB
      #-DZLIB_ROOT:PATH=${ZLIB_ROOT}
      #-DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
      #-DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
      #-DCMAKE_POLICY_DEFAULT_CMP0074:STRING=NEW # Explicitly set to NEW to ensure ZLIB_ROOT is not ignored.
      -DBUILD_ZLIB:BOOL=ON # See https://github.com/Slicer/SlicerOpenCV/issues/71

      # Dependencies: OpenCV_contrib
      -DOPENCV_EXTRA_MODULES_PATH:PATH=${OpenCV_contrib_SOURCE_DIR}/modules

      # Options: OpenCV_contrib
      -DBUILD_opencv_cnn_3dobj:BOOL=OFF # Require Caffe, Glog & Protobuf
      -DBUILD_opencv_hdf:BOOL=OFF # Require HDF5
      -DBUILD_opencv_julia:BOOL=OFF # Require JlCxx
      -DBUILD_opencv_ovis:BOOL=OFF # Require OGRE
      -DBUILD_opencv_sfm:BOOL=OFF # Require Ceres, Gflags & Glog
      -DBUILD_opencv_wechat_qrcode:BOOL=OFF # Require Iconv. See https://github.com/Slicer/SlicerOpenCV/issues/72
      -DWITH_TESSERACT:BOOL=OFF # text module

      # Install directories
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
      -DCMAKE_INSTALL_LIBDIR:STRING=${Slicer_INSTALL_THIRDPARTY_LIB_DIR} # Skip default initialization by GNUInstallDirs CMake module
      -DPYTHON3_PACKAGES_PATH:PATH=${Slicer_INSTALL_ROOT}${Slicer_BUNDLE_EXTENSIONS_LOCATION}${PYTHON_SITE_PACKAGES_SUBDIR}

      ${ADDITIONAL_OPENCV_ARGS}
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )


  set(OpenCV_DIR ${${proj}_INSTALL_DIR})
  if(UNIX)
    set(OpenCV_DIR ${${proj}_INSTALL_DIR}/${Slicer_INSTALL_THIRDPARTY_LIB_DIR}/cmake/opencv4/)
  endif()

  ExternalProject_GenerateProjectDescription_Step(${proj})
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
