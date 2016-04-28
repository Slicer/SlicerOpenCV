// MRML includes
#include "vtkMRMLScene.h"

// SlicerOpenCV includes
#include "vtkSlicerOpenCVLogic.h"

// VTK includes
#include <vtkIndent.h>
#include <vtkNew.h>
#include <vtkObjectFactory.h>

// ITK includes
#include <itkOpenCVVideoIOFactory.h>

int vtkSlicerOpenCVLogicTest1(int, char * [])
{
  vtkSmartPointer<vtkMRMLScene> scene = vtkSmartPointer<vtkMRMLScene>::New();

  vtkNew<vtkSlicerOpenCVLogic> logic1;
  logic1->SetMRMLScene(scene);

  vtkIndent indent;
  logic1->PrintSelf(std::cout, indent);

  // check that the OpenCV ITK IO factory was registered
  std::list< itk::ObjectFactoryBase * > factories;
  factories = itk::ObjectFactoryBase::GetRegisteredFactories();
  bool factoryFound = false;
  for (std::list<itk::ObjectFactoryBase*>::iterator it = factories.begin();
       it != factories.end();
       it++)
    {
    itk::ObjectFactoryBase *factory = *it;
    if (factory->GetNameOfClass())
      {
      if (!strcmp(factory->GetNameOfClass(), "OpenCVVideoIOFactory"))
        {
        factoryFound = true;
        std::cout << "Factory found: " << factory->GetNameOfClass() << std::endl;
        }
      }
    }
  if (!factoryFound)
    {
    std::cerr << "The OpenCV video IO factory was not registered with ITK!"
              << std::endl;
    return EXIT_FAILURE;
    }
  return EXIT_SUCCESS;
}
