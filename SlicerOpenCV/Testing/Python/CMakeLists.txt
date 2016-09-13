include(SlicerMacroBuildScriptedModule)
set(SLICEROPENCV_PYTHON_RESOURCES
  )

# Test calculating a histogram of an image from midas
slicerMacroBuildScriptedModule(
  NAME SlicerOpenCVSelfTest
  SCRIPTS SlicerOpenCVSelfTest.py
  RESOURCES ${SLICEROPENCV_PYTHON_RESOURCES}
  )
# on Windows, the build directory test doesn't work
if (NOT WIN32)
  MESSAGE(STATUS "Adding unit test for python wrapping")
  slicer_add_python_unittest(SCRIPT SlicerOpenCVSelfTest.py)
endif()
