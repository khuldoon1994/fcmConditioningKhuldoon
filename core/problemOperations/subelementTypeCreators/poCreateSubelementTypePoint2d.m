function [ newType ] = poCreateSubelementTypePoint2d( typeData )
% poCreateElementTypePoint2d Creates a point subelement.

    % create dummy funtion returing 1 as the shape function value
    newType.shapeFunctionEvaluator = @(problem, subelementIndex, r, derivative) [1];
    
    newType.numberOfNodalShapes = 1;
    newType.numberOfInternalShapes = 0;
    newType.localDimension = 0;
    
 end

