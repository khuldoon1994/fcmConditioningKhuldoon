function [ newType ] = poCreateSubelementTypeLegendreLine( typeData )

    p = moParseScalar('order', typeData, 2, 'typeData for subelement type LEGENDRE_LINE');
    
    newType.shapeFunctionEvaluator = @legendreLineShapeFunctions;
    newType.shapeFunctionEvaluatorData.order = p;
    
    newType.numberOfNodalShapes = 2;
    newType.numberOfInternalShapes = (p-1);
    newType.localDimension = 1;
    
 end

