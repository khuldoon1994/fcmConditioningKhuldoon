function [ newType ] = poCreateElementTypeDynamicLine1d( typeData )
% poCreateElementTypeDynamicLine1d Creates a dynamic one-dimensional line
% or truss element.
%
%   newType = poCreateElementTypeDynamicLine1d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   gaussOrder:    The gaussian order.
%   youngsModulus: The youngsModulus.
%   area:          The cross sectional area.
%   rho:           The mass density.
%  
%   Instead of calling this function directly, the function 
%   poCreateDynamicElementType may be used for convenience.
%   
%   See also p poCreateDynamicElementType, poCreateElementTypeDynamicLine2d, 
%   poCreateElementTypeDynamicQuad2d,

    %% parse input
    p = moParseScalar('gaussOrder',typeData,2,'typeData for element type DYNAMIC_LINE_1D');
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type DYNAMIC_LINE_1D');
    A = moParseScalar('area',typeData,1,'typeData for element type DYNAMIC_LINE_1D');
    rho = moParseScalar('massDensity',typeData,1,'typeData for element type DYNAMIC_LINE_1D');
    
    
    %% create type
    newType.name = 'DYNAMIC_LINE_1D';
    newType.localDimension = 1;
    
    newType.systemMatricesCreator = @standardDynamicSystemMatricesCreator;
    
    newType.quadraturePointGetter = @gaussianQuadrature1d;
    newType.quadraturePointGetterData.gaussOrder = p;
    
    newType.elasticityMatrixGetter = @linearElasticityMatrix1d;
    newType.elasticityMatrixGetterData.youngsModulus =  E;
    newType.elasticityMatrixGetterData.area = A;
    
    newType.massDensityGetter = @linearMassDensity;
    newType.massDensityGetterData.massDensity = rho;
    
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end

