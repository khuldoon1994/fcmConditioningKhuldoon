function [ C ] = linearElasticityMatrix1d(problem, elementIndex, r)

  elementTypeIndex = problem.elementTypeIndices(elementIndex);
  elementType = problem.elementTypes{elementTypeIndex};
  data = elementType.elasticityMatrixGetterData;

  E = moParseScalar('youngsModulus', data, 1.0, ['elasticity matrix getter data for element type ',elementType.name]);
  A = moParseScalar('area', data, 1.0, ['elasticity matrix getter data for element type ',elementType.name]);

  C = E * A;

end