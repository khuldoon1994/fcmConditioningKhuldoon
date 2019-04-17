function [ newType ] = poCreateSubelementTypeLinearQuad( typeData )
    
    newType.shapeFunctionEvaluator = @linearQuadShapeFunctions;
    newType.shapeFunctionEvaluatorData = {  };
    newType.numberOfNodalShapes = 4;
    newType.numberOfInternalShapes = 0;
    newType.localDimension = 2;

end

