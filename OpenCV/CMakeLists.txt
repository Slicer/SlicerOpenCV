
#-----------------------------------------------------------------------------
set(MODULE_NAME OpenCV)
set(MODULE_TITLE ${MODULE_NAME})

string(TOUPPER ${MODULE_NAME} MODULE_NAME_UPPER)

#-----------------------------------------------------------------------------
add_subdirectory(Logic)
# add_subdirectory(Widgets)

#-----------------------------------------------------------------------------
set(MODULE_EXPORT_DIRECTIVE "Q_SLICER_QTMODULES_${MODULE_NAME_UPPER}_EXPORT")

# Current_{source,binary} and Slicer_{Libs,Base} already included
set(MODULE_INCLUDE_DIRECTORY_BASE ${CMAKE_CURRENT_BINARY_DIR}/../${Slicer_QTLOADABLEMODULES_LIB_DIR}/include)
# needs the base as well as subdirs due to how files are included in opencv and ITK
set(MODULE_INCLUDE_DIRECTORIES
  ${CMAKE_CURRENT_SOURCE_DIR}/Logic
  ${CMAKE_CURRENT_BINARY_DIR}/Logic
  ${MODULE_INCLUDE_DIRECTORY_BASE}
  ${MODULE_INCLUDE_DIRECTORY_BASE}/opencv
  ${MODULE_INCLUDE_DIRECTORY_BASE}/ITK-4.8
  )

set(MODULE_SRCS
  qSlicer${MODULE_NAME}Module.cxx
  qSlicer${MODULE_NAME}Module.h
  )

set(MODULE_MOC_SRCS
  qSlicer${MODULE_NAME}Module.h
  )

set(MODULE_UI_SRCS
  )

# point to the opencv libraries
set(OPENCV_LIBRARY_PATH ${CMAKE_CURRENT_BINARY_DIR}/../${Slicer_QTLOADABLEMODULES_LIB_DIR}/lib)
MESSAGE(STATUS "OPENCV_LIBRARY_PATH = ${OPENCV_LIBRARY_PATH}")
link_directories(${OPENCV_LIBRARY_PATH})

set(MODULE_TARGET_LIBRARIES
  vtkSlicer${MODULE_NAME}ModuleLogic
  )

set(TARGET_LINK_LIBRARIES
  ${CMAKE_CURRENT_BINARY_DIR}/${Slicer_QTLOADABLEMODULES_LIB_DIR}/lib
  )

set(MODULE_RESOURCES
  )

#-----------------------------------------------------------------------------
slicerMacroBuildQtModule(
  NAME ${MODULE_NAME}
  TITLE ${MODULE_TITLE}
  EXPORT_DIRECTIVE ${MODULE_EXPORT_DIRECTIVE}
  INCLUDE_DIRECTORIES ${MODULE_INCLUDE_DIRECTORIES}
  SRCS ${MODULE_SRCS}
  MOC_SRCS ${MODULE_MOC_SRCS}
  UI_SRCS ${MODULE_UI_SRCS}
  TARGET_LIBRARIES ${MODULE_TARGET_LIBRARIES}
  RESOURCES ${MODULE_RESOURCES}
  )

#-----------------------------------------------------------------------------
if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()
