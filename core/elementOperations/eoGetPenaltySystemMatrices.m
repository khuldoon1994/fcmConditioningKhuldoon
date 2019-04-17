function [ Kp, Fp ] = eoGetPenaltySystemMatrices(problem, elementIndex)
% eoGetPenaltySystem Gets the penalty stiffnes matrix and penalty load
% vector for an element.

    % get number of degrees of freedom
    nShapes = eoGetNumberOfShapeFunctions(problem,elementIndex);
    dimension = problem.dimension;
    nDof = nShapes*dimension;
    
    % initialize penalty matrices
    Kp = zeros(nDof, nDof);
    Fp = zeros(nDof, 1);
    
    % nonzero internal shapes
    nonZeroInternalShapeIndices = eoGetNonZeroInternalShapeIndices(problem,elementIndex);
        
    %% internal penalties - always homogeneous
    penaltyIndices = problem.elementPenalties{elementIndex};
    
    % loop over penalties
    nPenalties = length(penaltyIndices);
    for iLoad = 1:nPenalties
        
        % get a copy of the current penalty
        penalty = problem.penalties{penaltyIndices(iLoad)};
        
        % loop over dimensions
        for iDim = 1:dimension
            
            % get indices
            indices=(nonZeroInternalShapeIndices-1)*dimension+iDim;
            
            % insert values
            Fp(indices) = 0;
            for i = 1:numel(indices)
                Kp(indices(i),indices(i)) = penalty(iDim,2);
            end
        end
    end

    %% nodal penalties
    [ nodeIndices, shapeIndices ] = eoGetNodalShapeIndices(problem,elementIndex);
    nNodalShapes = numel(nodeIndices);
    
    % loop over element nodal shapes
    for iNodalShape = 1:nNodalShapes

        % get global node index
        nodeIndex = nodeIndices(iNodalShape);
        
        % get local shape index
        shapeIndex = shapeIndices(iNodalShape);

        % get penalty indices for current node
        penaltyIndices = problem.nodePenalties{nodeIndex};

        % loop over penalties
        nPenalties = numel(penaltyIndices);
        for iPenalty = 1:nPenalties
            % get a copy of the current penalty
            penalty = problem.penalties{penaltyIndices(iPenalty)};

            % loop over dimensions
            for iDim = 1:dimension
                % get indices
                index=dimension*(shapeIndex-1)+iDim;

                % insert values
                Fp(index) = penalty(iDim,1) .* penalty(iDim,2);
                Kp(index,index) = penalty(iDim,2);
            end
        end
    end

end


