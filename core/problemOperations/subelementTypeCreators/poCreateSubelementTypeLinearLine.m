function [ newType ] = poCreateSubelementTypeLinearLine( typeData )
%createLinearLineElementType Creates the respective element type.
   
    newType.shapeFunctionEvaluator = @linearLineShapeFunctions;
    newType.shapeFunctionEvaluatorData = { };
    newType.numberOfNodalShapes = 2;
    newType.numberOfInternalShapes = 0;
    newType.localDimension = 1;

end

