function [ newType ] = poCreateSubelementTypeLagrangeLine( typeData )

    p = moParseScalar('order', typeData, 2, 'typeData for subelement type LAGRANGE_LINE');
    
    if ~isfield(typeData, 'samplingPoints')
       typeData.samplingPoints = linspace(-1,1,p+1);
    end
    
    newType.shapeFunctionEvaluator = @lagrangeLineShapeFunctions;
    newType.shapeFunctionEvaluatorData.order = p;
    newType.shapeFunctionEvaluatorData.samplingPoints = typeData.samplingPoints;
        
    newType.numberOfNodalShapes = 2;
    newType.numberOfInternalShapes = (p-1);
    newType.localDimension = 1;
    
 end

