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

// Qt includes
#include <QtPlugin>

// OpenCV Logic includes
//#include <vtkSlicerOpenCVLogic.h>

// OpenCV includes
#include "qSlicerOpenCVModule.h"
//#include "qSlicerOpenCVModuleWidget.h"

//-----------------------------------------------------------------------------
Q_EXPORT_PLUGIN2(qSlicerOpenCVModule, qSlicerOpenCVModule);

//-----------------------------------------------------------------------------
/// \ingroup Slicer_QtModules_ExtensionTemplate
class qSlicerOpenCVModulePrivate
{
public:
  qSlicerOpenCVModulePrivate();
};

//-----------------------------------------------------------------------------
// qSlicerOpenCVModulePrivate methods

//-----------------------------------------------------------------------------
qSlicerOpenCVModulePrivate::qSlicerOpenCVModulePrivate()
{
}

//-----------------------------------------------------------------------------
// qSlicerOpenCVModule methods

//-----------------------------------------------------------------------------
qSlicerOpenCVModule::qSlicerOpenCVModule(QObject* _parent)
  : Superclass(_parent)
  , d_ptr(new qSlicerOpenCVModulePrivate)
{
}

//-----------------------------------------------------------------------------
qSlicerOpenCVModule::~qSlicerOpenCVModule()
{
}

//-----------------------------------------------------------------------------
QString qSlicerOpenCVModule::helpText() const
{
  return "This is a loadable module that can be bundled in an extension";
}

//-----------------------------------------------------------------------------
QString qSlicerOpenCVModule::acknowledgementText() const
{
  return "This work was partially funded by NIH grant NXNNXXNNNNNN-NNXN";
}

//-----------------------------------------------------------------------------
QStringList qSlicerOpenCVModule::contributors() const
{
  QStringList moduleContributors;
  moduleContributors << QString("Nicole Aucoin (BWH)");
  return moduleContributors;
}

//-----------------------------------------------------------------------------
QIcon qSlicerOpenCVModule::icon() const
{
  return QIcon(":/Icons/OpenCV.png");
}

//-----------------------------------------------------------------------------
QStringList qSlicerOpenCVModule::categories() const
{
  return QStringList() << "Libraries";
}

//-----------------------------------------------------------------------------
QStringList qSlicerOpenCVModule::dependencies() const
{
  return QStringList();
}

//-----------------------------------------------------------------------------
void qSlicerOpenCVModule::setup()
{
  this->Superclass::setup();
}

//-----------------------------------------------------------------------------
qSlicerAbstractModuleRepresentation* qSlicerOpenCVModule
::createWidgetRepresentation()
{
  return NULL;
}

//-----------------------------------------------------------------------------
vtkMRMLAbstractLogic* qSlicerOpenCVModule::createLogic()
{
  return NULL;
}
