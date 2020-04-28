function [ newType ] = poCreateElementTypeDynamicLine2d( typeData )
%poCreateElementTypeDynamicLine2d  Creates a dynamic two-dimensional line
% or truss element.
%
%   newType = poCreateElementTypeDynamicLine2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   gaussOrder:    The gaussian order.
%   youngsModulus: The youngsModulus.
%   nu:            The poissonRatio.
%   area:          The cross sectional area.
%   rho:           The mass density.
%  
%   Instead of calling this function directly, the function 
%   poCreateDynamicElementType may be used for convenience.
%   
%   See also p poCreateElementType, poCreateElementTypeDynamicLine1d, 
%   poCreateElementTypeDynamicQuad2d,

    %% parse input
    p = moParseScalar('gaussOrder',typeData,2,'typeData for element type DYNAMIC_LINE_2D');
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type DYNAMIC_LINE_2D');
    nu = moParseScalar('poissonRatio',typeData,1,'typeData for element type DYNAMIC_LINE_2D');
    rho = moParseScalar('massDensity',typeData,1,'typeData for element type DYNAMIC_LINE_2D');
    
    physics = moParseString('physics',typeData, 'PLAIN_STRAIN', 'typeData for element type DYNAMIC_LINE_2D');
    elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    if strcmp(physics,'PLANE_STRESS')
        elasticityMatrixGetter=@linearPlaneStressElasticityMatrix;
    elseif strcmp(physics,'PLANE_STRAIN')
        elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    else
        warning(['WARNIN! Unknown physics "',physics,'" given in typeData for element type DYNAMIC_LINE_2D. Assuming PLANE_STRAIN.']);
    end
    
    %% create type
    newType.name = 'DYNAMIC_LINE_2D';
    
    newType.localDimension = 1;
    
    newType.systemMatricesCreator = @boundaryDynamicSystemMatricesCreator;
    
    newType.quadraturePointGetter = @gaussianQuadrature1d;
    newType.quadraturePointGetterData.gaussOrder = p;
    
    newType.elasticityMatrixGetter = elasticityMatrixGetter;
    newType.elasticityMatrixGetterData.youngsModulus = E;
    newType.elasticityMatrixGetterData.poissonRatio = nu;
    
    newType.massDensityGetter = @linearMassDensity;
    newType.massDensityGetterData.massDensity = rho;
    
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end

