/*==============================================================================

  Program: 3D Slicer

  Portions (c) Copyright Brigham and Women's Hospital (BWH) All Rights Reserved.

  See COPYRIGHT.txt
  or http://www.slicer.org/copyright/copyright.txt for details.

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

==============================================================================*/

// .NAME vtkSlicerOpenCVLogic - slicer logic class for OpenCV library
// .SECTION Description
// This class manages the logic associated with reading, saving,
// and changing properties of the OpenCV library


#ifndef __vtkSlicerOpenCVLogic_h
#define __vtkSlicerOpenCVLogic_h

// Slicer includes
#include "vtkSlicerModuleLogic.h"

// MRML includes

// STD includes
#include <cstdlib>

#include "vtkSlicerOpenCVModuleLogicExport.h"


/// \ingroup Slicer_QtModules_ExtensionTemplate
class VTK_SLICER_OPENCV_MODULE_LOGIC_EXPORT vtkSlicerOpenCVLogic :
  public vtkSlicerModuleLogic
{
public:

  static vtkSlicerOpenCVLogic *New();
  vtkTypeMacro(vtkSlicerOpenCVLogic, vtkSlicerModuleLogic);
  void PrintSelf(ostream& os, vtkIndent indent);

protected:
  vtkSlicerOpenCVLogic();
  virtual ~vtkSlicerOpenCVLogic();

  virtual void SetMRMLSceneInternal(vtkMRMLScene* newScene);
  /// Register MRML Node classes to Scene. Gets called automatically when the MRMLScene is attached to this logic class.
  virtual void RegisterNodes();
  virtual void UpdateFromMRMLScene();
  virtual void OnMRMLSceneNodeAdded(vtkMRMLNode* node);
  virtual void OnMRMLSceneNodeRemoved(vtkMRMLNode* node);

private:

  vtkSlicerOpenCVLogic(const vtkSlicerOpenCVLogic&); // Not implemented
  void operator=(const vtkSlicerOpenCVLogic&); // Not implemented
};

#endif
