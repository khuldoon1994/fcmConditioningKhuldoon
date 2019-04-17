function [ subelementIndices ] = eoGetCoincidingSubelements( problem, elementIndex )
% eoGetCoincidingSubelements Gets the indices of all subelements that coincide
% with the current element, i.e. all subelements that have the same nodes.

    % get the element node indices
    elementNodeIndices = problem.elementNodeIndices{elementIndex};

    % initialize return value
    subelementIndices = [];
    
    % loop over connections
    connections = problem.elementConnections{elementIndex};
    nConnections = numel(connections);
    for iConnection = 1:nConnections
       subelementIndex = connections{iConnection}{1};
       subelementNodeIndices = problem.subelementNodeIndices{subelementIndex};
       if moListsCoincide(elementNodeIndices,subelementNodeIndices)
           subelementIndices = [subelementIndices iConnection]; %#ok
       end
    end
end

