function [ newType ] = poCreateElementTypeStandardTruss2d( typeData )
%poCreateElementTypeStandardTruss2d  Creates a dynamic two-dimensional line
% or truss element.
%
%   newType = poCreateElementTypeStandardTruss2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   youngsModulus: The youngsModulus.
%   nu:            The poissonRatio.
%   area:          The cross sectional area.
%   rho:           The mass density.
%  
%   Instead of calling this function directly, the function 
%   poCreateStandardElementType may be used for convenience.
%   
%   See also poCreateElementType, poCreateElementTypeStandardQuad2d,

    %% parse input
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type STANDARD_TRUSS_2D');
    A = moParseScalar('area',typeData,1,'typeData for element type STANDARD_TRUSS_2D');
    rho = moParseScalar('massDensity',typeData,1,'typeData for element type STANDARD_TRUSS_2D');

    %% create type
    newType.name = 'STANDARD_TRUSS_2D';
    
    newType.localDimension = 2;
    
    newType.systemMatricesCreator = @standardTruss2dSystemMatricesCreator;
    newType.dynamicSystemMatricesCreator = @dynamicTruss2dSystemMatricesCreator;
    
    newType.youngsModulus = E;
    newType.area = A;
    newType.massDensity = rho;
    
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end

