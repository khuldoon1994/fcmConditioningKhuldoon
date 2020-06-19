function [ newType ] = poCreateSubelementTypeHermiteLine( typeData )
%createHermiteLineElementType Creates the respective element type.
   
    newType.shapeFunctionEvaluator = @hermiteLineShapeFunctions;
    newType.shapeFunctionEvaluatorData = { };
    newType.numberOfNodalShapes = 2;
    newType.numberOfInternalShapes = 2;
    newType.localDimension = 1;

end

