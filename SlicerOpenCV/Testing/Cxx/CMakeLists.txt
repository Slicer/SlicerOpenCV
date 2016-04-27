set(KIT qSlicer${MODULE_NAME}Module)

#-----------------------------------------------------------------------------
find_package(ITK COMPONENTS ITKVideoBridgeOpenCV REQUIRED)
include(${ITK_USE_FILE})

#-----------------------------------------------------------------------------
set(KIT_TEST_SRCS
  #qSlicer${MODULE_NAME}ModuleTest.cxx
  vtkSlicerOpenCVLogicTest1.cxx
  )

#-----------------------------------------------------------------------------
slicerMacroConfigureModuleCxxTestDriver(
  NAME ${KIT}
  SOURCES ${KIT_TEST_SRCS}
  TARGET_LIBRARIES ${ITK_LIBRARIES}
  WITH_VTK_DEBUG_LEAKS_CHECK
  )

#-----------------------------------------------------------------------------
#simple_test(qSlicer${MODULE_NAME}ModuleTest)

simple_test(vtkSlicerOpenCVLogicTest1)
