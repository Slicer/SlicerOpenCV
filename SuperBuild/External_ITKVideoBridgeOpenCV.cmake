#-----------------------------------------------------------------------------
# Build the ITK OpenCV bridge, pointing it to Slicer's ITK and this build
# of OpenCV

set(proj ITKVideoBridgeOpenCV)

# Dependencies
set(${proj}_DEPENDENCIES OpenCV)
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

set(ITK_SOURCE_DIR ${ITK_DIR}/../ITKv4)
set(${proj}_SOURCE_DIR ${ITK_SOURCE_DIR}/Modules/Video/BridgeOpenCV)
ExternalProject_Message(${proj} "ITK_SOURCE_DIR:${ITK_SOURCE_DIR}")
ExternalProject_Message(${proj} "${proj}_SOURCE_DIR:${${proj}_SOURCE_DIR}")

# don't allow using the system ITK, use the Slicer one
set(${proj}_BINARY_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  # build from Slicer's ITK into the extension's ITK build dir
  DOWNLOAD_COMMAND ""
  SOURCE_DIR ${${proj}_SOURCE_DIR}
  BINARY_DIR ${${proj}_BINARY_DIR}
  INSTALL_COMMAND ""
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    -DCMAKE_BUILD_TYPE:STRING=Debug
    # to find ITKConfig.cmake
    -DITK_DIR:PATH=${ITK_DIR}
    -DBUILD_TESTING:BOOL=OFF
    # OpenCV
    -DOpenCV_INCLUDE_DIRS:STRING=${OpenCV_INCLUDE_DIR};${OpenCV_INCLUDE_DIR}/opencv
    -DOpenCV_LIB_DIR:PATH=${OpenCV_DIR}/lib
    -DOpenCV_DIR:PATH=${OpenCV_DIR}/share/OpenCV
    -DOpenCV_LIB_DIR_DBG:PATH=${OpenCV_DIR}/lib
    -DOpenCV_LIB_DIR_OPT:PATH=${OpenCV_DIR}/lib
    -DOpenCV_LIBS:STRING=opencv_core;opencv_videoio;opencv_imgproc
  DEPENDS ${${proj}_DEPENDENCIES}
)

set(${proj}_DIR ${${proj}_BINARY_DIR})
mark_as_superbuild(VARS ${proj}_DIR:PATH)

ExternalProject_Message(${proj} "${proj}_DIR:${${proj}_DIR}")
