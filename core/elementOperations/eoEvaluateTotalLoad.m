function [ totalLoad ] = eoEvaluateTotalLoad( problem, elementIndex, r )
%calculateLoad Caculates the load vector (body load or traction) for an element

    % initialize return value
    totalLoad = zeros(problem.dimension,1);

    % get load indices for this element
    loadIndices = problem.elementLoads{elementIndex};
        
    % sum up total load
    nLoads = length(loadIndices);
    for iLoad = 1:nLoads
        
        % get a copy of the current load
        load = problem.loads{loadIndices(iLoad)};
        
        % add value to total load
        if isnumeric(load)
            % load is constant
            totalLoad = totalLoad + load;    
        else
            % load is a function of the global position
            X=eoEvaluateMapping(problem,elementIndex,r);
            totalLoad = totalLoad + load(X);
        end
        
    end

end

