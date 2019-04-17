function [ newType ] = poCreateElementTypeDynamicQuad2d( typeData )
% poCreateElementTypeDynamicQuad2d Creates a dynamic two-dimensional 
% quad element
%
%   newType = poCreateElementTypeDynamicQuad2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   gaussOrder:    The gaussian order.
%   physics:       PLAIN_STRAIN or PLAIN_STRESS
%   youngsModulus: The youngsModulus.
%   nu:            The poissonRatio.
%   area:          The cross sectional area.
%   rho:           The mass density.
%   kappa:         The damping coefficient.
%  
%   Instead of calling this function directly, the function 
%   poCreateDynamicElementType may be used for convenience.
%   
%   See also p poCreateDynamicElementType, poCreateElementTypeDynamicLine1d, 
%   poCreateElementTypeDynamicLine2d.

    %% parse input
    p = moParseScalar('gaussOrder',typeData,2,'typeData for element type DYNAMIC_QUAD_2D');
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type DYNAMIC_QUAD_2D');
    nu = moParseScalar('poissonRatio',typeData,1,'typeData for element type DYNAMIC_QUAD_2D');
    rho = moParseScalar('massDensity',typeData,1,'typeData for element type DYNAMIC_QUAD_2D');
    kappa = moParseScalar('dampingCoefficient',typeData,0,'typeData for element type DYNAMIC_QUAD_2D');

    physics = moParseString('physics',typeData, 'PLAIN_STRAIN', 'typeData for element type DYNAMIC_QUAD_2D');
    elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    if strcmp(physics,'PLANE_STRESS')
        elasticityMatrixGetter=@linearPlaneStressElasticityMatrix;
    elseif strcmp(physics,'PLANE_STRAIN')
        elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    else
        warning(['WARNIN! Unknown physics "',physics,'" given in typeData for element type DYNAMIC_QUAD_2D. Assuming PLANE_STRAIN.']);
    end
    
    %% create type
    newType.name = 'DYNAMIC_QUAD_2D';
    
    newType.localDimension = 2;
    newType.mappingEvaluator = @linearQuadMapping;
    newType.jacobianEvaluator = @linearQuadJacobian;
    newType.mapperData = { };
    
    newType.systemMatricesCreator = @standardDynamicSystemMatricesCreator;
    
    newType.quadraturePointGetter = @gaussianQuadrature2d;
    newType.quadraturePointGetterData.gaussOrder = p;
    
    newType.elasticityMatrixGetter = elasticityMatrixGetter;
    newType.elasticityMatrixGetterData.youngsModulus = E;
    newType.elasticityMatrixGetterData.poissonRatio = nu;
    
    newType.dynamicMaterialGetter = @linearDynamicMaterial;
    newType.dynamicMaterialGetterData.massDensity = rho;
    newType.dynamicMaterialGetterData.dampingCoefficient = kappa;
    
    newType.elementPlotter = @plotLinearQuad;
    newType.postGridCellCreator = @createQuadPostGridCells;
end

