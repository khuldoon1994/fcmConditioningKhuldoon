function [ newType ] = poCreateSubelementTypeLegendreQuad( typeData )
    
    p = moParseScalar('order', typeData, 2, 'typeData for subelement type LEGENDRE_QUAD');
    
    newType.shapeFunctionEvaluator = @legendreQuadShapeFunctions;
    newType.shapeFunctionEvaluatorData.order = p;
    
    newType.numberOfNodalShapes = 4;
    newType.numberOfInternalShapes = (p-1)*(p-1);
    newType.localDimension = 2;

end

