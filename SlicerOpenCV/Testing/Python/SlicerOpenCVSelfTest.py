import os
import unittest
import vtk, qt, ctk, slicer
from slicer.ScriptedLoadableModule import *
import logging
import numpy as np

print 'Current SlicerOpenCVSelfTest.py path = '
scriptPath = os.path.dirname(os.path.abspath(__file__))
print scriptPath


# load the python wrapped OpenCV module
try:
  print 'Trying to import cv2'
  # the module is in the python path
  import cv2
  print 'Imported!'
except ImportError:
  print 'Trying to import from file'
  # for the build directory, load from the file
  import imp, platform
  if platform.system() == 'Windows':
    cv2File = 'cv2.pyd'
    cv2Path = '../../../../OpenCV-build/lib/Release/' + cv2File
  else:
    cv2File = 'cv2.so'
    cv2Path = '../../../../OpenCV-build/lib/' + cv2File
  cv2Path = os.path.abspath(os.path.join(scriptPath, cv2Path))
  # in the build directory, this path should exist, but in the installed extension
  # it should be in the python path, so only use the short file name
  if not os.path.isfile(cv2Path):
    print 'Full path not found: ',cv2Path
    cv2Path = cv2File
  print 'Loading cv2 from ',cv2Path
  cv2 = imp.load_dynamic('cv2', cv2File)

#
# SlicerOpenCVSelfTest
#

class SlicerOpenCVSelfTest(ScriptedLoadableModule):
  """Uses ScriptedLoadableModule base class, available at:
  https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
  """

  def __init__(self, parent):
    ScriptedLoadableModule.__init__(self, parent)
    self.parent.title = "SlicerOpenCVSelfTest"
    self.parent.categories = ["Testing.TestCases"]
    self.parent.dependencies = ["SlicerOpenCV"]
    self.parent.contributors = ["Nicole Aucoin (BWH)"]
    self.parent.helpText = """
    This is an example of how to use OpenCV from python.
    It performs a simple histogram on the input vector volume and optionally captures a screenshot.
    """
    self.parent.acknowledgementText = """
    This file was originally developed by Nicole Aucoin, BWH.
"""

#
# SlicerOpenCVSelfTestWidget
#

class SlicerOpenCVSelfTestWidget(ScriptedLoadableModuleWidget):
  """Uses ScriptedLoadableModuleWidget base class, available at:
  https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
  """

  def setup(self):
    ScriptedLoadableModuleWidget.setup(self)

    # Instantiate and connect widgets ...

    #
    # Parameters Area
    #
    parametersCollapsibleButton = ctk.ctkCollapsibleButton()
    parametersCollapsibleButton.text = "Parameters"
    self.layout.addWidget(parametersCollapsibleButton)

    # Layout within the dummy collapsible button
    parametersFormLayout = qt.QFormLayout(parametersCollapsibleButton)

    #
    # input volume selector
    #
    self.inputSelector = slicer.qMRMLNodeComboBox()
    self.inputSelector.nodeTypes = ["vtkMRMLVectorVolumeNode"]
    self.inputSelector.selectNodeUponCreation = True
    self.inputSelector.addEnabled = False
    self.inputSelector.removeEnabled = False
    self.inputSelector.noneEnabled = False
    self.inputSelector.showHidden = False
    self.inputSelector.showChildNodeTypes = False
    self.inputSelector.setMRMLScene( slicer.mrmlScene )
    self.inputSelector.setToolTip( "Pick the input to the histogram." )
    parametersFormLayout.addRow("Input Volume: ", self.inputSelector)

    #
    # check box to trigger taking screen shots for later use in tutorials
    #
    self.enableScreenshotsFlagCheckBox = qt.QCheckBox()
    self.enableScreenshotsFlagCheckBox.checked = 0
    self.enableScreenshotsFlagCheckBox.setToolTip("If checked, take screen shots for tutorials. Use Save Data to write them to disk.")
    parametersFormLayout.addRow("Enable Screenshots", self.enableScreenshotsFlagCheckBox)

    #
    # Apply Button
    #
    self.applyButton = qt.QPushButton("Apply")
    self.applyButton.toolTip = "Run the algorithm."
    self.applyButton.enabled = False
    parametersFormLayout.addRow(self.applyButton)

    # connections
    self.applyButton.connect('clicked(bool)', self.onApplyButton)
    self.inputSelector.connect("currentNodeChanged(vtkMRMLNode*)", self.onSelect)

    # Add vertical spacer
    self.layout.addStretch(1)

    # Refresh Apply button state
    self.onSelect()

  def cleanup(self):
    pass

  def onSelect(self):
    self.applyButton.enabled = self.inputSelector.currentNode() and self.outputSelector.currentNode()

  def onApplyButton(self):
    logic = SlicerOpenCVSelfTestLogic()
    enableScreenshotsFlag = self.enableScreenshotsFlagCheckBox.checked
    logic.run(self.inputSelector.currentNode(), enableScreenshotsFlag)

#
# SlicerOpenCVSelfTestLogic
#

class SlicerOpenCVSelfTestLogic(ScriptedLoadableModuleLogic):
  """This class should implement all the actual
  computation done by your module.  The interface
  should be such that other python code can import
  this class and make use of the functionality without
  requiring an instance of the Widget.
  Uses ScriptedLoadableModuleLogic base class, available at:
  https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
  """

  def takeScreenshot(self,name,description,type=-1):
    # show the message even if not taking a screen shot
    slicer.util.delayDisplay('Take screenshot: '+description+'.\nResult is available in the Annotations module.', 3000)

    lm = slicer.app.layoutManager()
    # switch on the type to get the requested window
    widget = 0
    if type == slicer.qMRMLScreenShotDialog.FullLayout:
      # full layout
      widget = lm.viewport()
    elif type == slicer.qMRMLScreenShotDialog.ThreeD:
      # just the 3D window
      widget = lm.threeDWidget(0).threeDView()
    elif type == slicer.qMRMLScreenShotDialog.Red:
      # red slice window
      widget = lm.sliceWidget("Red")
    elif type == slicer.qMRMLScreenShotDialog.Yellow:
      # yellow slice window
      widget = lm.sliceWidget("Yellow")
    elif type == slicer.qMRMLScreenShotDialog.Green:
      # green slice window
      widget = lm.sliceWidget("Green")
    else:
      # default to using the full window
      widget = slicer.util.mainWindow()
      # reset the type so that the node is set correctly
      type = slicer.qMRMLScreenShotDialog.FullLayout

    # grab and convert to vtk image data
    qpixMap = qt.QPixmap().grabWidget(widget)
    qimage = qpixMap.toImage()
    imageData = vtk.vtkImageData()
    slicer.qMRMLUtils().qImageToVtkImageData(qimage,imageData)

    annotationLogic = slicer.modules.annotations.logic()
    annotationLogic.CreateSnapShot(name, description, type, 1, imageData)

  def hist_curve(self, im):
    h = np.zeros((300,256,3))
    if len(im.shape) == 2:
        color = [(255,255,255)]
    elif im.shape[2] == 3:
        color = [ (255,0,0),(0,255,0),(0,0,255) ]
    for ch, col in enumerate(color):
        hist_item = cv2.calcHist([im],[ch],None,[256],[0,256])
        cv2.normalize(hist_item,hist_item,0,255,cv2.NORM_MINMAX)
        hist=np.int32(np.around(hist_item))
        pts = np.int32(np.column_stack((self.bins,hist)))
        cv2.polylines(h,[pts],False,col)
    y=np.flipud(h)
    return y

  def hist_lines(self, im):
    h = np.zeros((300,256,3))
    if len(im.shape)!=2:
        print("hist_lines applicable only for grayscale images")
        #print("so converting image to grayscale for representation"
        im = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
    hist_item = cv2.calcHist([im],[0],None,[256],[0,256])
    cv2.normalize(hist_item,hist_item,0,255,cv2.NORM_MINMAX)
    hist=np.int32(np.around(hist_item))
    for x,y in enumerate(hist):
        cv2.line(h,(x,0),(x,y),(255,255,255))
    y = np.flipud(h)
    return y

  def run(self, inputVolume, enableScreenshots=0):
    """
    Do a histogram of an input image.
    Based on OpenCV-source/samples/python/hist.py
    """

    logging.info('Processing started')

    id = inputVolume.GetID()
    # get the file name to re-read with OpenCV
    fname = inputVolume.GetStorageNode().GetFileName()
    logging.info('File name = %s' % fname)
    im = cv2.imread(fname)

    if im is None:
        print('Failed to load image file:', fname)
        return False

    if enableScreenshots:
      self.takeScreenshot('SlicerOpenCVSelfTestTest-Start','OpenCVHistogramScreenshot',-1)

    # Compute the histogram using the OpenCV hist function
    self.bins = np.arange(256).reshape(256,1)

    gray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)


    # Histogram plotting

    cv2.imshow('image',im)

    slicer.util.delayDisplay('Showing histogram for color image in curve mode', 1000)
    curve = self.hist_curve(im)
    cv2.imshow('histogram',curve)
    cv2.imshow('image',im)

    slicer.util.delayDisplay('Showing histogram in bin mode', 1000)
    lines = self.hist_lines(im)
    cv2.imshow('histogram',lines)
    cv2.imshow('image',gray)

    slicer.util.delayDisplay('Showing equalized histogram (always in bin mode)', 1000)
    equ = cv2.equalizeHist(gray)
    lines = self.hist_lines(equ)
    cv2.imshow('histogram',lines)
    cv2.imshow('image',equ)

    slicer.util.delayDisplay('Showing histogram for color image in curve mode', 1000)
    curve = self.hist_curve(gray)
    cv2.imshow('histogram',curve)
    cv2.imshow('image',gray)

    slicer.util.delayDisplay('Showing histogram for a normalized image in curve mode', 1000)
    norm = cv2.normalize(gray, gray, alpha = 0,beta = 255,norm_type = cv2.NORM_MINMAX)
    lines = self.hist_lines(norm)
    cv2.imshow('histogram',lines)
    cv2.imshow('image',norm)

    slicer.util.delayDisplay('Done showing histogram options', 1000)
    cv2.destroyAllWindows()

    # Capture screenshot
    if enableScreenshots:
      self.takeScreenshot('SlicerOpenCVSelfTestTest-End','HistogramScreenshot',-1)

    logging.info('Processing completed')

    return True


class SlicerOpenCVSelfTestTest(ScriptedLoadableModuleTest):
  """
  This is the test case for your scripted module.
  Uses ScriptedLoadableModuleTest base class, available at:
  https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
  """

  def setUp(self):
    """ Do whatever is needed to reset the state - typically a scene clear will be enough.
    """
    slicer.mrmlScene.Clear(0)

  def runTest(self):
    """Run as few or as many tests as needed here.
    """
    self.setUp()
    self.test_SlicerOpenCVSelfTest1()

  def test_SlicerOpenCVSelfTest1(self):

    self.delayDisplay("Starting the test")
    #
    # first, get some data
    #
    import urllib
    downloads = (
        ('http://slicer.kitware.com/midas3/download/item/253131', 'TCGA-XJ-A9DX-01Z-00-DX1_appMag_40_29_38-256x256-180.png', slicer.util.loadVolume),
        )

    for url,name,loader in downloads:
      filePath = slicer.app.temporaryPath + '/' + name
      if not os.path.exists(filePath) or os.stat(filePath).st_size == 0:
        logging.info('Requesting download %s from %s...\n' % (name, url))
        urllib.urlretrieve(url, filePath)
      if loader:
        logging.info('Loading %s...' % (name,))
        properties = {'singleFile' : 0}
        loader(filePath, properties)
    self.delayDisplay('Finished with download and loading')

    volumeNode = slicer.util.getNode(pattern="TCGA-XJ-A9DX-01Z-00-DX1_appMag_40_29_38-256x256-180")
    logic = SlicerOpenCVSelfTestLogic()

    logic.run(volumeNode)

    self.delayDisplay('Test passed!')
