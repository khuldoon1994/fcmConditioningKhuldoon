function [F] = goCreateNodalLoadVector(problem)

% gather information
nNodes = size(problem.nodes,2);
dim = problem.dimension;
nTotalDof = goNumberOfDof(problem);

% compute load vector
F = zeros(nTotalDof,1);
for i=1:nNodes
   loadVector = zeros(dim,1);
   loadIndices = problem.nodeLoads{i};
   for k=1:numel(loadIndices)
        loadIndex = loadIndices(k);
        load = problem.loads{loadIndex};
        % add value to total load
        if isnumeric(load)
            % load is constant
            loadVector = loadVector + load;    
        else
            t = problem.dynamics.time;
            loadVector = loadVector + load(t);
        end

    end
    for j=1:dim
        F((i-1)*dim+j) = loadVector(j);
    end

end