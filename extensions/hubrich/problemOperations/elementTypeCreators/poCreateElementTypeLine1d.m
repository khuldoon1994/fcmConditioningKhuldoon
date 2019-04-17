function [ newType ] = poCreateElementTypeLine1d( typeData )
%poCreateElementTypeLine1d Creates the respective cell type.
%   typeData must be sth. like
%   { quadratureType }

    %% check input
    if numel(typeData)<6
        msg = 'WARNING! Not enough entries in element type data for LINE_1D. Need 6.';
        warning(msg)
    end
    
    quadratureType.name = 'gaussLegendre';
    quadratureType.order = 2;
    quadratureType.setupQuadraturePoints = @eoSetupGaussLegendre1d;
    if ~strcmp(typeData{1},'gaussLegendre') || ~isscalar(typeData{2})
        msg = 'WARNING: Wrong quadrature input data of function poCreateElementTypeLine1d. Assume Gauss-Legendre quadratureType of order p_q=2!';
        warning(msg)
    else
        quadratureType.name = typeData{1};
        quadratureType.order = typeData{2};
    end
    
    E = 1;
    if ~strcmp(typeData{3},'youngsModulus') || ~isscalar(typeData{4})
        msg = 'WARNING! No youngsModulus given for element type LINE_1D. Assuming 1!';
        warning(msg);
    else
        E = typeData{4};
    end
    
    A = 1.0;
    if ~strcmp(typeData{5},'area') || ~isscalar(typeData{6})
        msg = 'WARNING! No area given for element type STANDARD_LINE_1D. Assuming 1.';
        warning(msg)
    else
        A = typeData{6};
    end
    
    %% create type
    newType.name = 'HUBRICH_LINE';
    newType.localDimension = 1;
    
    newType.systemMatricesCreator = @eoStandardSystemMatricesCreator;
    
    newType.quadratureType = quadratureType;
%    newType.quadraturePointGetter = @gaussianQuadrature1d;
%    newType.quadraturePointGetterData = { 'gaussOrder', p };
    
    newType.elasticityMatrixGetter = @linearElasticityMatrix1d;
    newType.elasticityMatrixGetterData = {'youngsModulus',E,'area', A };

    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
end

