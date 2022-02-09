set(proj OpenCV)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SYSTEM_${proj})
  unset(OpenCV_DIR CACHE)
  find_package(OpenCV 4.1 REQUIRED)
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
    "55445db730b54144c5855606dd523ec0f3cc0ab5" # slicer-4.1.2-55445d
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
    1a5bc64b981bb2d2945f6499a3adbad12aad54bf # slicer-4.1.2-2020.02.22-1a5bc6
    QUIET
    )

  set(${proj}_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj})
  set(${proj}_INSTALL_DIR ${CMAKE_BINARY_DIR}/${proj}-install)

  if(APPLE)
    # Workaround for OpenCV 3.2+ and OSX clang compiler issues
    list(APPEND ADDITIONAL_OPENCV_ARGS -DBUILD_PROTOBUF:BOOL=OFF)
  endif()

  option(SlicerOpenCV_USE_CUDA "Enable or disable the building of CUDA modules" OFF)

  # Determine numpy include folder (if exists)
  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import pkg_resources;pkg=pkg_resources.get_distribution('numpy');print(pkg.location)" 
    OUTPUT_VARIABLE _numpy_location
    ERROR_VARIABLE _numpy_error)
  if(NOT _numpy_location)
    message("numpy package not found in python distribution. OpenCV python bindings won't be generated.")
  else()
    file(TO_CMAKE_PATH ${_numpy_location} _numpy_location)
    string(STRIP ${_numpy_location} _numpy_location)
    list(APPEND ADDITIONAL_OPENCV_ARGS
          -DPYTHON3_NUMPY_INCLUDE_DIRS:PATH=${_numpy_location}/numpy/core/include
          )
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${${SUPERBUILD_TOPLEVEL_PROJECT}_${proj}_GIT_REPOSITORY}"
    GIT_TAG "${${SUPERBUILD_TOPLEVEL_PROJECT}_${proj}_GIT_TAG}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${proj}-build
    INSTALL_DIR ${${proj}_INSTALL_DIR}
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=${CMAKE_CXX_STANDARD_REQUIRED}
      -DCMAKE_CXX_EXTENSIONS:BOOL=${CMAKE_CXX_EXTENSIONS}
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
      -DWITH_EIGEN:BOOL=OFF
      -DVTK_DIR:PATH=${VTK_DIR}
      # Disable OpenCL: Initially disabled because of build errors on MacOSX 10.6 (See #17)
      -DWITH_OPENCL:BOOL=OFF
      -DCUDA_GENERATION:STRING=${Slicer_CUDA_GENERATION}
      -DWITH_CUDA:BOOL=${SlicerOpenCV_USE_CUDA}
      # Disable find_package(Java) so that java wrapping is not done
      -DCMAKE_DISABLE_FIND_PACKAGE_JAVA:BOOL=ON
      # Add Python wrapping, use Slicer's python
      -DOPENCV_SKIP_PYTHON_LOADER:BOOL=ON
      -DOPENCV_PYTHON_EXTRA_DEFINITIONS:STRING=CV_RELEASE_PYTHON
      -DPYTHON3_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
      -DPYTHON3_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
      -DPYTHON3_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
      -DPYTHON3_NUMPY_INCLUDE_DIRS:PATH=
      -DINSTALL_PYTHON_EXAMPLES:BOOL=OFF
      # install the python package in the third party lib dir
      -DPYTHON3_PACKAGES_PATH:PATH=${Slicer_INSTALL_ROOT}${Slicer_BUNDLE_EXTENSIONS_LOCATION}${PYTHON_SITE_PACKAGES_SUBDIR}
      ${ADDITIONAL_OPENCV_ARGS}
      -DOPENCV_EXTRA_MODULES_PATH:PATH=${OpenCV_contrib_SOURCE_DIR}/modules
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )


  set(OpenCV_DIR ${${proj}_INSTALL_DIR})
  if(UNIX)
    set(OpenCV_DIR ${${proj}_INSTALL_DIR}/lib/cmake/opencv4/)
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
