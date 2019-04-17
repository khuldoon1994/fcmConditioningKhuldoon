function [ newType ] = poCreateElementTypeStandardLine1d( typeData )
% poCreateElementTypeStandardLine1d Creates a standard one-dimensional line
% or truss element.
%
%   newType = poCreateElementTypeStandardLine1d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   gaussOrder:    The gaussian order.
%   youngsModulus: The youngsModulus.
%   area:          The cross sectional area.
%  
%   Instead of calling this function directly, the function 
%   poCreateElementType may be used for convenience.
%   
%   See also p poCreateElementType, poCreateElementTypeStandardLine2d, 
%   poCreateElementTypeStandardQuad2d,

    %% parse input
    p = moParseScalar('gaussOrder',typeData,2,'typeData for element type STANDARD_LINE_1D');
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type STANDARD_LINE_1D');
    A = moParseScalar('area',typeData,1,'typeData for element type STANDARD_LINE_1D');
    
    
    %% create type
    newType.name = 'STANDARD_LINE_1D';
    newType.localDimension = 1;
    
    newType.systemMatricesCreator = @standardSystemMatricesCreator;
    
    newType.quadraturePointGetter = @gaussianQuadrature1d;
    newType.quadraturePointGetterData.gaussOrder = p;
    
    newType.elasticityMatrixGetter = @linearElasticityMatrix1d;
    newType.elasticityMatrixGetterData.youngsModulus =  E;
    newType.elasticityMatrixGetterData.area = A;

    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end
