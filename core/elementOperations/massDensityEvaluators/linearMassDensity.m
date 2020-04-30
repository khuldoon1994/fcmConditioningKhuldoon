function [ rho ] = linearMassDensity(problem, elementIndex, r)

  elementTypeIndex = problem.elementTypeIndices(elementIndex);
  elementType = problem.elementTypes{elementTypeIndex};
  data = elementType.massDensityGetterData;

  rho = moParseScalar('massDensity', data, 1.0, ['mass density getter data for element type ',elementType.name]);
  
end