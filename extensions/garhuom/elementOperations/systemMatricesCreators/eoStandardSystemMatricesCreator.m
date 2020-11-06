function [ Ke, Fe ] = eoStandardSystemMatricesCreator(problem, elementIndex)
    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % initialize matrices
    Ke=zeros(nDof,nDof);
    Fe=zeros(nDof,1);

    % create copy of function handles for shorter notation
%    quadraturePointGetter = problem.elementTypes{elementTypeIndex}.quadraturePointGetter;
    elasticityMatrixGetter = problem.elementTypes{elementTypeIndex}.elasticityMatrixGetter;

    % create quadrature points
%    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
    points = problem.elementQuadratures{elementIndex}.points;
    weights = problem.elementQuadratures{elementIndex}.weights;
    
    nPoints = numel(weights);

    % loop over quadrature points
    for i=1:nPoints
        
        % copy the local coordinates of this quadrature point
        localCoordinates = points(:,i);
        
        % shape functions and mapping evaluation
        shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, localCoordinates);
        shapeFunctionGlobalDerivatives = eoEvaluateShapeFunctionGlobalDerivative(problem,elementIndex,localCoordinates);
        jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates);
        detJ = det(jacobian);
        
        % add stiffness matrix integrand
        B = moComposeStrainDisplacementMatrix(shapeFunctionGlobalDerivatives);
        C = elasticityMatrixGetter(problem, elementIndex, localCoordinates);
        Ke = Ke + B'*C*B * weights(i) * detJ;
        
        % add load vector integrand
        N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
        b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
        Fe = Fe + N'*b * weights(i) * detJ;
        
        % add elastic foundation integrand
        c = eoEvaluateTotalFoundationStiffness(problem, elementIndex, localCoordinates);
        Ke = Ke + N'* c * N * weights(i) * detJ;
    end

    %% only if epsilon is pre defined apply the stablization
    if(isfield(problem, 'stablization'))
        % apply eigenvalue stablization if cell is broken
        status = isCellBroken2D(problem, elementIndex)

        epsilon = problem.stablization.epsilon;
        tolerenceEig = problem.stablization.tolerenceEig;
        tolerenceStrain = problem.stablization.tolerenceStrain;

        if(status == 'isBroken' & epsilon>0)
            fprintf('===================== Eigenvalues stablization =====================\n')
            %Ke
            %isSym = issymmetric(Ke)
            fprintf('## Element: %d\n', elementIndex)

            rank_ele = rank(Ke);
            size_ele = size(Ke,2);
            difference_rank_size = size_ele - rank_ele

            fprintf('## compute eigenvalues \n')
            [V,D] = qdwheig(Ke);
            eigValues = diag(D);

            maxEigBeforeStablization = max(eigValues);

            % remove zero eigenvalues
            eigValues(eigValues <= 1.0e-9) = inf;
            b = min(eigValues,[],2);

            minEigBeforeStablization = min(b)
            maxEigBeforeStablization
            conditionBeforeStablization = abs(maxEigBeforeStablization/minEigBeforeStablization)

            % get the modes that need to be stablized
            fprintf('## detect the modes that need to be stablized \n')
            [V_hat, D_hat,RBM] = getModesToBeStablizedBasedOnStrains(V,diag(D),B, C, tolerenceEig, tolerenceStrain);
            number_of_detected_rigid_body_modes = RBM
            number_of_detected_bad_modes = size(D_hat,2)
            
            if(isempty(D_hat))
                fprintf('## No stablization is needed for this element! \n')
            end

            % stablize the modes
            if(~isempty(D_hat))
                fprintf('## stablize the modes \n')
                d = Fe;
                [Ke, Fe]=applyEigenvalueStablization(Ke, Fe, d, V_hat, D_hat, maxEigBeforeStablization, epsilon);
                
                % check the condition number after stablization 
                eigValues = qdwheig(Ke);
                maxEigAfterStablization = max(eigValues);

                % remove zero eigenvalues
                eigValues(eigValues <= 1.0e-9) = inf;
                b = min(eigValues,[],2);

                minEigAfterStablization = min(b)
                maxEigAfterStablization
                conditionAfterStablization = abs(maxEigAfterStablization/minEigAfterStablization)
            end
        end
    end
    
    %% add penalty constraints
    [ Kp, Fp ] = eoGetPenaltySystemMatrices(problem, elementIndex);

    Ke = Ke + Kp;
    Fe = Fe + Fp;
   
end 