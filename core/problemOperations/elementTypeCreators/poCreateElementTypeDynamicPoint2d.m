function [ newType ] = poCreateElementTypeDynamicPoint2d( typeData )
% poCreateElementTypeDynamicPoint2d Creates a two dimensional point mass, i.e.
% a point mass that can move in two-dimensional space.
%
%   newType = poCreateElementTypeDynamicPoint2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   mass:    The mass of the point
%  
%   Instead of calling this function directly, the function 
%   poCreateElementType may be used for convenience.
%   
%   See also poCreateElementType, poCreateElementTypeStandardLine2d, 
%   poCreateElementTypeStandardQuad2d,

    %% parse input
    mass = moParseScalar('mass',typeData,1,'typeData for element type STANDARD_LINE_1D');
    
    
    %% create type
    newType.name = 'DYNAMIC_POINT_2D';
    newType.localDimension = 0;
    
    newType.systemMatricesCreator = @pointMassDynamicSystemMatricesCreator;
    
    newType.mass = mass;
    
    newType.mappingEvaluator = @pointMapping;
    
    newType.elementPlotter = @plotPoint;
    newType.postGridCellCreator = @(problem, elementIndex, cuts) cell(0,1);
    
end
