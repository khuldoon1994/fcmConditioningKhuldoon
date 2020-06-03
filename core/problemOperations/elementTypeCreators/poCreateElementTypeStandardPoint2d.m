function [ newType ] = poCreateElementTypeStandardPoint2d( typeData )
% poCreateElementTypeStandardPoint2d Creates a two dimensional point mass, i.e.
% a point mass that can move in two-dimensional space.
%
%   newType = poCreateElementTypeStandardPoint2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   mass:    The mass.
%  
%   Instead of calling this function directly, the function 
%   poCreateElementType may be used for convenience.
%   
%   See also poCreateElementType, poCreateElementTypeStandardLine2d, 
%   poCreateElementTypeStandardQuad2d,

    %% parse input
    mass = moParseScalar('mass',typeData,1.0,'typeData for element type STANDARD_POINT_2D');
    
    
    %% create type
    newType.name = 'STANDARD_POINT_2D';
    newType.localDimension = 0;
    
    newType.systemMatricesCreator = @standardPointMassSystemMatricesCreator;
    newType.dynamicSystemMatricesCreator = @dynamicPointMassSystemMatricesCreator;
    
    newType.mass = mass;
    
    newType.mappingEvaluator = @pointMapping;
    
    newType.elementPlotter = @plotPoint;
    newType.postGridCellCreator = @(problem, elementIndex, cuts) cell(0,1);
    
end
