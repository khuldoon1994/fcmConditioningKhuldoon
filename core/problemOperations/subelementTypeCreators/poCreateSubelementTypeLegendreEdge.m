function [ newType ] = poCreateSubelementTypeLegendreEdge( typeData )
% poCreateElementTypeLegendreEdge Creates a subelement type without nodal
% modes to be used as part of a higher dimensional element.


    p = moParseScalar('order', typeData, 2, 'typeData for subelement type LEGENDRE_EDGE');
    
    newType.shapeFunctionEvaluator = @legendreEdgeShapeFunctions;
    newType.shapeFunctionEvaluatorData.order = p;
    
    newType.numberOfNodalShapes = 0;
    newType.numberOfInternalShapes = (p-1);
    newType.localDimension = 1;
    
 end

