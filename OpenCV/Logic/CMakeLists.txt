project(vtkSlicer${MODULE_NAME}ModuleLogic)

set(KIT ${PROJECT_NAME})

#-----------------------------------------------------------------------------
find_package(ITK COMPONENTS ITKVideoBridgeOpenCV REQUIRED)
include(${ITK_USE_FILE})

#-----------------------------------------------------------------------------
set(${KIT}_EXPORT_DIRECTIVE "VTK_SLICER_${MODULE_NAME_UPPER}_MODULE_LOGIC_EXPORT")

set(MODULE_INCLUDE_DIRECTORY_BASE ${CMAKE_CURRENT_BINARY_DIR}/../../${Slicer_QTLOADABLEMODULES_LIB_DIR}/include)

set(${KIT}_INCLUDE_DIRECTORIES
  ${MODULE_INCLUDE_DIRECTORY_BASE}/opencv
  )
message(STATUS "${KIT} include dirs = ${${KIT}_INCLUDE_DIRECTORIES}")

set(${KIT}_SRCS
  vtkSlicer${MODULE_NAME}Logic.cxx
  vtkSlicer${MODULE_NAME}Logic.h
  )

#set(MODULE_TARGET_LIBRARY_BASE ${CMAKE_CURRENT_BINARY_DIR}/../../${Slicer_QTLOADABLEMODULES_LIB_DIR}/lib)
#message(STATUS "Logic target library base = ${MODULE_TARGET_LIBRARY_BASE}")
#link_directories(${MODULE_TARGET_LIBRARY_BASE})

set(${KIT}_TARGET_LIBRARIES
  opencv_videoio
  ${ITK_LIBRARIES}
  )

#-----------------------------------------------------------------------------
SlicerMacroBuildModuleLogic(
  NAME ${KIT}
  EXPORT_DIRECTIVE ${${KIT}_EXPORT_DIRECTIVE}
  INCLUDE_DIRECTORIES ${${KIT}_INCLUDE_DIRECTORIES}
  SRCS ${${KIT}_SRCS}
  TARGET_LIBRARIES ${${KIT}_TARGET_LIBRARIES}
  )
