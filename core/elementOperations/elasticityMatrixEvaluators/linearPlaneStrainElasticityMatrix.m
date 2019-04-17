function [ C ] = linearPlaneStrainElasticityMatrix(problem, elementIndex, r)

    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    elementType = problem.elementTypes{elementTypeIndex};
    data = elementType.elasticityMatrixGetterData;

    E = moParseScalar('youngsModulus', data, 1.0, ['elasticity matrix getter data for element type ',elementType.name]);
    nu = moParseScalar('poissonRatio', data, 0.0, ['elasticity matrix getter data for element type ',elementType.name]);
  
    C = E / ((1.0+nu)*(1.0-2.0*nu)) * [1.0-nu    nu      0.0;
                                         nu    1.0-nu    0.0;
                                        0.0     0.0   0.5*(1.0-2.0*nu) ];

end

