function [ newType ] = poCreateElementTypeDynamicTruss2d( typeData )
%poCreateElementTypeDynamicTruss2d  Creates a dynamic two-dimensional line
% or truss element.
%
%   newType = poCreateElementTypeDynamicTruss2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   youngsModulus: The youngsModulus.
%   nu:            The poissonRatio.
%   area:          The cross sectional area.
%   rho:           The mass density.
%   kappa:         The damping coefficient.
%  
%   Instead of calling this function directly, the function 
%   poCreateDynamicElementType may be used for convenience.
%   
%   See also p poCreateElementType, poCreateElementTypeDynamicQuad2d,

    %% parse input
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type DYNAMIC_TRUSS_2D');
    A = moParseScalar('area',typeData,1,'typeData for element type DYNAMIC_TRUSS_2D');
    rho = moParseScalar('massDensity',typeData,1,'typeData for element type DYNAMIC_TRUSS_2D');
    kappa = moParseScalar('dampingCoefficient',typeData,0,'typeData for element type DYNAMIC_TRUSS_2D');

    %% create type
    newType.name = 'DYNAMIC_TRUSS_2D';
    
    newType.localDimension = 1;
    
    newType.systemMatricesCreator = @truss2dDynamicSystemMatricesCreator;
    
    newType.youngsModulus = E;
    newType.area = A;
    
    % TODO: Remove linearDynamicMaterial from the code
    %newType.dynamicMaterialGetter = @linearDynamicMaterial;
    %newType.dynamicMaterialGetterData.massDensity = rho;
    %newType.dynamicMaterialGetterData.dampingCoefficient = kappa;
    
    newType.massDensity = rho;
    newType.dampingCoefficient = kappa;
    
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end

