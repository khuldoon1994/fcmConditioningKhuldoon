function [ newType ] = poCreateElementTypeStandardLine2d( typeData )
%poCreateElementTypeStandardLine2d  Creates a standard two-dimensional line
% element that is usually used for integrating edge loads.
%
%   newType = poCreateElementTypeStandardLine2d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   gaussOrder:    The gaussian order.
%   physics:       PLAIN_STRAIN or PLAIN_STRESS
%   youngsModulus: The youngsModulus.
%   nu:            The poissonRatio.
%   thickness:     The thickness.
%   rho:           The mass density. (optional)
%  
%   Instead of calling this function directly, the function 
%   poCreateElementType may be used for convenience.
%   
%   See also poCreateElementType, poCreateElementTypeStandardLine2d, 
%   poCreateElementTypeStandardQuad2d,


    %% parse input
    p = moParseScalar('gaussOrder',typeData,2,'typeData for element type STANDARD_LINE_2D');
    E = moParseScalar('youngsModulus',typeData,1.0,'typeData for element type STANDARD_LINE_2D');
    nu = moParseScalar('poissonRatio',typeData,1.0,'typeData for element type STANDARD_LINE_2D');
    d = moParseScalar('thickness',typeData,1.0,'typeData for element type STANDARD_LINE_2D');
    rho = moParseScalarWithoutWarning('massDensity', typeData, 1.0);

    %% TODO: Why is this needed? It's a boundary element...  
    physics = moParseString('physics',typeData, 'PLAIN_STRAIN', 'typeData for element type STANDARD_LINE_2D');
    elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    if strcmp(physics,'PLANE_STRESS')
        elasticityMatrixGetter=@linearPlaneStressElasticityMatrix;
    elseif strcmp(physics,'PLANE_STRAIN')
        elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    else
        warning(['WARNIN! Unknown physics "',physics,'" given in typeData for element type STANDARD_LINE_2D. Assuming PLANE_STRAIN.']);
    end
    
    %% create type
    newType.name = 'STANDARD_LINE_2D';
    
    newType.localDimension = 1;
    
    newType.quadraturePointGetter = @gaussianQuadrature1d;
    newType.quadraturePointGetterData.gaussOrder = p;
    
    newType.systemMatricesCreator = @boundarySystemMatricesCreator;
    newType.dynamicSystemMatricesCreator = @dynamicBoundarySystemMatricesCreator;
    
    %% TODO: Why is this needed? It's a boundary element...
    %% thickness is needed
    newType.elasticityMatrixGetter = elasticityMatrixGetter;
    newType.elasticityMatrixGetterData.youngsModulus = E;
    newType.elasticityMatrixGetterData.poissonRatio = nu;
    
    newType.massDensity = rho;
    newType.thickness = d;
    
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end

