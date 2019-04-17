function newType = poCreateElementTypeLine2d( typeData )
%poCreateElementTypeLine2d Summary of this function goes here
%   Detailed explanation goes here

%% TODO: Implementation
% have a look at:
%   - "poCreateElementTypeLine1d.m" 
%   - "poCreateElementTypeStandardLine2d.m"

 %% check input
    if numel(typeData)<8
       disp('ERROR! Not enough entries in element type data for STANDARD_LINE_2D. Need 8.');
    end
    

%      p = 2;
%     if ~strcmp(typeData{1},'gaussOrder') || ~isscalar(typeData{2})
%         disp('ERROR! No gaussOrder given for element type STANDARD_LINE_2D. Assuming 2.');
%     else
%         p = typeData{2};
%     end

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
    
    elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
    if ~strcmp(typeData{3},'physics') || ~ischar(typeData{4})
        disp('ERROR! No physic given for element type STANDARD_LINE_2D. Assuming PLANE_STRAIN.');
    else
        if strcmp(typeData{4},'PLANE_STRESS')
            elasticityMatrixGetter=@linearPlaneStressElasticityMatrix;
        elseif strcmp(typeData{4},'PLANE_STRAIN')
            elasticityMatrixGetter=@linearPlaneStrainElasticityMatrix;
        else
            disp('ERROR! No physic given for element type STANDARD_LINE_2D. Assuming PLANE_STRAIN.');
        end
    end
    
    E = 1;
    if ~strcmp(typeData{5},'youngsModulus') || ~isscalar(typeData{6})
        disp('ERROR! No youngsModulus given for cell type STANDARD_LINE_2D. Assuming 1.');
    else
        E = typeData{6};
    end
    
    nu = 0.0;
    if ~strcmp(typeData{7},'poissonRatio') || ~isscalar(typeData{8})
        disp('ERROR! No poissonRatio given for cell type STANDARD_LINE_2D. Assuming 0.');
    else
        nu = typeData{8};
    end
    
    %% create type
    newType.localDimension = 1;
    
      newType.quadratureType = quadratureType;
%     newType.quadraturePointGetter = @gaussianQuadrature1d;
%     newType.quadraturePointGetterData = { 'gaussOrder', p };
%     
    newType.systemMatricesCreator = @eoBoundarySystemMatricesCreator;
    
    newType.elasticityMatrixGetter = elasticityMatrixGetter;
    newType.elasticityMatrixGetterData = {'youngsModulus',E,'poissonRatio',nu };
    
    newType.mappingEvaluator = @linearLineMapping;
    newType.jacobianEvaluator = @linearLineJacobian;
    
    newType.elementPlotter = @plotLinearLine;
    newType.postGridCellCreator = @createLinePostGridCells;
    
end


