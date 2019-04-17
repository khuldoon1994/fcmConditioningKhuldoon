function [ newType ] = poCreateFCMElementTypeLine1d( typeData )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%    %% check input
%     if numel(typeData)<14
%         msg = 'WARNING! Not enough entries in element type data for poCreateFCMElementTypeLine1d. Need 12.';
%         warning(msg)
%     end

infoStr = 'typeData for element type FCM_LINE_2D';    
    %% physical domain input
    % iside:    levelSetFunction <= 0
    % outside:  levelSetFunction > 0
    levelSetFunction = moParseFunctionHandle('levelSetFunction',typeData,@(x) 0, infoStr);
    
    %% quadrature input
       qpGetter = @setupAdaptiveGaussLegendre2d;
    quadratureRule = moParseString('quadratureRule', typeData, 'ADAPTIVE_GAUSS_LEGENDRE', infoStr);
    
    if strcmp(quadratureRule,'ADAPTIVE_GAUSS_LEGENDRE')
        qpGetter = @setupAdaptiveGaussLegendre1d;
    elseif strcmp(quadratureRule,'MOMENT_FITTING_GAUSS_LEGENDRE')
        qpGetter = @setupMomentFittingGaussLegendre1d;
    else
        quadratureRule = ADAPTIVE_GAUSS_LEGENDRE;
        warning('WARNING: Field "quadratureRule" in data for element type FCM_LINE_2D needs to be one of (ADAPTIVE_GAUSS_LEGENDRE,MOMENT_FITTING_GAUSS_LEGENDRE). Assuming 2.!');
    end
     gaussOrder = moParseScalar('gaussOrder',typeData,2,infoStr);
    depth = moParseScalar('depth',typeData,3,infoStr);
    alphaFCM = moParseScalar('alphaFCM',typeData,0.0,infoStr);
    
    %% physics input
    
    E = moParseScalar('youngsModulus',typeData,1,'typeData for element type FCM_QUAD_2D');
    nu = moParseScalar('poissonRatio',typeData,1,'typeData for element type FCM_QUAD_2D');
    
    physics = moParseString('physics',typeData, 'PLAIN_STRAIN', 'typeData for element type STANDARD_QUAD_2D');
    elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    if strcmp(physics,'PLANE_STRESS')
        elasticityMatrixGetter=@linearPlaneStressElasticityMatrix;
    elseif strcmp(physics,'PLANE_STRAIN')
        elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    else
        warning(['WARNIN! Unknown physics "',physics,'" given in typeData for element type STANDARD_QUAD_2D. Assuming PLANE_STRAIN.']);
    end
   
    
    %% create type
    newType.name = 'FCM_LINE_2D';
    
    newType.localDimension = 1;
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    newType.mapperData = { };
    
    newType.systemMatricesCreator = @eoBoundarySystemMatricesCreator;
    
    newType.quadraturePointGetter = @predefinedQuadrature;
    newType.quadraturePointGetterData.levelSetFunction = levelSetFunction;
    newType.quadraturePointGetterData.quadratureRule = quadratureRule;
    newType.quadraturePointGetterData.gaussOrder = gaussOrder;
    newType.quadraturePointGetterData.depth = depth;
    newType.quadraturePointGetterData.alphaFCM = alphaFCM;
    newType.quadraturePointGetterData.setupQuadraturePoints = qpGetter;
    
    newType.elasticityMatrixGetter = elasticityMatrixGetter;
    newType.elasticityMatrixGetterData = {'youngsModulus',E,'poissonRatio',nu };
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
end

