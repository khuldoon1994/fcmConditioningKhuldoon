function [ newType ] = poCreateFCMElementTypeLine1d( typeData )
%poCreateElementTypeLine1d Creates the respective cell type.
%   typeData must be sth. like
%   { quadratureType }

    %% check input
    if numel(typeData)<12
        msg = 'WARNING! Not enough entries in element type data for poCreateFCMElementTypeLine1d. Need 12.';
        warning(msg)
    end
    
    %% physical domain input
    % iside:    physicalDomainTestFunction <= 0
    % outside:  physicalDomainTestFunction > 0
    if strcmp(typeData{1},'physicalDomain') && isa(typeData{2},'function_handle')
        physicalDomainTestFunction = typeData{2};
    else
        physicalDomainTestFunction=@(x) 0;
        msg = 'WARNING: poCreateFCMElementTypeLine1d needs a physicalDomainTestFunction. Assume physicalDomainTestFunction=@(x) 0!';
        warning(msg)
    end
    
    %% quadrature input
    if strcmp(typeData{3},'adaptiveGaussLegendre') && isscalar(typeData{4})
        quadratureType.setupQuadraturePoints = @eoSetupAdaptiveGaussLegendre1d;
        quadratureType.name = typeData{3};
        quadratureType.order = typeData{4};
        if strcmp(typeData{5},'depth') && isscalar(typeData{6})
            quadratureType.depth = typeData{6};
        else
            msg = 'WARNING: Adaptive-Gauss-Legendre quadratureType needs a Tree-Depth-Level. Assume depth=3!';
            warning(msg)
        end
    elseif strcmp(typeData{3},'momentFittingGaussLegendre') && isscalar(typeData{4})
        quadratureType.setupQuadraturePoints = @eoSetupMomentFittingGaussLegendre1d;
        quadratureType.name = typeData{3};
        quadratureType.order = typeData{4};
        if strcmp(typeData{5},'depth') && isscalar(typeData{6})
            quadratureType.depth = typeData{6};
        else
            msg = 'WARNING: Moment-Fitting-Gauss-Legendre quadratureType needs a Tree-Depth-Level. Assume depth=3!';
            warning(msg)
        end
    else
        quadratureType.name = 'adaptiveGaussLegendre';
        quadratureType.order = 2;
        quadratureType.depth = 3;
        quadratureType.setupQuadraturePoints = @eoSetupAdaptiveGaussLegendre1d;
        msg = 'WARNING: Wrong quadrature input data of function poCreateFCMElementTypeLine1d. Assume Adaptive-Gauss-Legendre quadratureType of order p_q=2 with Tree-Depth-Level depth=3!';
        warning(msg)
    end
    
    if ~strcmp(typeData{7},'alphaFCM') && ~isscalar(typeData{8})
        quadratureType.alphaFCM = 0.0;
        msg = 'WARNING: Input variable alphaFCM for poCreateFCMElementTypeLine1d has not been defined. Assume alphaFCM=0.0!';
        warning(msg)
    else
        quadratureType.alphaFCM = typeData{8};
    end
    
    %% physics input
    E = 1;
    if ~strcmp(typeData{9},'youngsModulus') && ~isscalar(typeData{10})
        msg = 'WARNING! No youngsModulus given for element type poCreateFCMElementTypeLine1d. Assuming 1!';
        warning(msg);
    else
        E = typeData{10};
    end
    
    A = 1.0;
    if ~strcmp(typeData{11},'area') && ~isscalar(typeData{12})
        msg = 'WARNING! No area given for element type poCreateFCMElementTypeLine1d. Assuming 1.';
        warning(msg)
    else
        A = typeData{12};
    end
    
    %% create type
    newType.name = 'FCM_LINE_1D';
    newType.localDimension = 1;
    
    newType.physicalDomainTestFunction = physicalDomainTestFunction;
    
    newType.systemMatricesCreator = @eoStandardSystemMatricesCreator;
    
    newType.quadratureType = quadratureType;
    
    newType.elasticityMatrixGetter = @linearElasticityMatrix1d;
    newType.elasticityMatrixGetterData = {'youngsModulus',E,'area', A };

    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
end

