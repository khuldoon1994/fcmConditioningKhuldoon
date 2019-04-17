function [ Le ] = eoGetLocationVector(problem, elementIndex, allLse)
% Create the location vector for a given element

    % get connections to subelements
    connections = problem.elementConnections{elementIndex};
    nConnections = numel(connections);
    
    % count number of dof
    nElementDof = zeros(nConnections,1);
    for iConnection = 1:nConnections
        elementIndex = connections{iConnection}{1};
        nElementDof(iConnection) = numel(allLse{elementIndex});
    end

    % create location vector
    Le = zeros(sum(nElementDof),1);
    index = 0;
    for iConnection = 1:nConnections
        elementIndex = connections{iConnection}{1};
        Le(index+1:index+nElementDof(iConnection)) = allLse{elementIndex};
        index = index + nElementDof(iConnection);
    end
    
end

