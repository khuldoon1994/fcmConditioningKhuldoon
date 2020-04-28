function [ rho ] = linearDynamicMaterial(problem, elementIndex, r)

  elementTypeIndex = problem.elementTypeIndices(elementIndex);
  elementType = problem.elementTypes{elementTypeIndex};
  data = elementType.dynamicMaterialGetterData;

  rho = moParseScalar('massDensity', data, 1.0, ['dynamic material getter data for element type ',elementType.name]);
  
end