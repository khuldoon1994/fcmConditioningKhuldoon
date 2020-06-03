%TODO: Cleanup, Documentation
function [ newType ] = poCreateElementTypeFCMLine1d( typeData )
% poCreateElementTypeFCMLine1d Creates a one-dimensional line element
% for an FCM analysis.
%
%   newType = poCreateElementTypeFCMLine1d(typeData) creates a new
%   type according to the parameters given in typeData.
%
%   typeData must be a structure array with the following fields:
%   quadratureRule: ADAPTIVE_GAUSS_LEGENDRE or MOMENT_FITTING_GAUSS_LEGENDRE
%   depth:          Line tree depth.
%   alphaFCM:       Alpha value for quadrature points in the fict. domain.
%   gaussOrder:     The gaussian order.
%   youngsModulus:  The youngsModulus.
%   area:           The cross sectional area.
%  
%   Instead of calling this function directly, the function 
%   poCreateElementType may be used for convenience.
%   
%   See also p poCreateElementType, poCreateElementTypeStandardLine1d, 
%   poCreateElementTypeStandardLine1d.


%poCreateElementTypeLine1d Creates the respective cell type.
%   typeData must be sth. like
%   { quadratureType }

    
    infoStr = 'typeData for element type FCM_LINE_1D';
    
    %% parse input
    % level set function
    % iside:    levelSetFunction <= 0
    % outside:  levelSetFunction > 0
    levelSetFunction = moParseFunctionHandle('levelSetFunction',typeData,@(x) 0, infoStr);
    
    
    % quadrature rule
    qpGetter = @setupAdaptiveGaussLegendre1d;
    quadratureRule = moParseString('quadratureRule', typeData, 'ADAPTIVE_GAUSS_LEGENDRE', infoStr);
    
    if strcmp(quadratureRule,'ADAPTIVE_GAUSS_LEGENDRE')
        qpGetter = @setupAdaptiveGaussLegendre1d;
    elseif strcmp(quadratureRule,'MOMENT_FITTING_GAUSS_LEGENDRE')
        qpGetter = @setupMomentFittingGaussLegendre1d;
    else
        quadratureRule = ADAPTIVE_GAUSS_LEGENDRE;
        warning('WARNING: Field "quadratureRule" in data for element type FCM_LINE_1D needs to be one of (ADAPTIVE_GAUSS_LEGENDRE,MOMENT_FITTING_GAUSS_LEGENDRE). Assuming 2.!');
    end
    
    gaussOrder = moParseScalar('gaussOrder',typeData,2,infoStr);
    depth = moParseScalar('depth',typeData,3,infoStr);
    alphaFCM = moParseScalar('alphaFCM',typeData,0.0,infoStr);
    
    
    %% physics input
    E = moParseScalar('youngsModulus',typeData,1.0,infoStr);
    A = moParseScalar('area',typeData,1.0,infoStr);
    
    
    %% create type
    newType.name = 'FCM_LINE_1D';
    newType.localDimension = 1;
    
    newType.systemMatricesCreator = @standardSystemMatricesCreator;
    
    newType.quadraturePointGetter = @predefinedQuadrature;
    newType.quadraturePointGetterData.levelSetFunction = levelSetFunction;
    newType.quadraturePointGetterData.quadratureRule = quadratureRule;
    newType.quadraturePointGetterData.gaussOrder = gaussOrder;
    newType.quadraturePointGetterData.depth = depth;
    newType.quadraturePointGetterData.alphaFCM = alphaFCM;
    newType.quadraturePointGetterData.setupQuadraturePoints = qpGetter;

    newType.elasticityMatrixGetter = @linearElasticityMatrix1d;
    newType.elasticityMatrixGetterData.youngsModulus = E;
    
    newType.area = A;

    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
end


