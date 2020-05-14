function [F] = goCreateNodalLoadVector(problem)

% gather information
nNodes = size(problem.nodes,2);
dim = problem.dimension;
nTotalDof = goNumberOfDof(problem);

% compute load vector
F = zeros(nTotalDof,1);
for i=1:nNodes
   loadVector = zeros(2,1);
   loadIndices = problem.nodeLoads{1};
   for k=1:numel(loadIndices)
        loadIndex = loadIndices(k);
        load = problem.loads(loadIndex);
        % add value to total load
        if isnumeric(load)
            % load is constant
            loadVector = loadVector + load;    
        else
            loadVector = loadVector + load(problem.dynamics.time);
        end

    end
    for j=1:dim
        F((i-1)*dim+j) = loadVector(j);
    end

end