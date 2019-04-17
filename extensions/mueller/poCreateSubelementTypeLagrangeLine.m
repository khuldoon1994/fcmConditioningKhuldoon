function [ newType ] = poCreateSubelementTypeLagrangeLine( typeData )

    p = moParseScalar('order', typeData, 2, 'typeData for subelement type LAGRANGE_LINE');
    
    newType.shapeFunctionEvaluator = @lagrangeLineShapeFunctions;
    newType.shapeFunctionEvaluatorData.order = p;
    
    newType.numberOfNodalShapes = 2;
    newType.numberOfInternalShapes = (p-1);
    newType.localDimension = 1;
    
 end

