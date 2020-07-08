function [ problem ] = poCreateSubElements2( problem )

    if problem.dimension == 1

        % create one subelement per element

        nElements = numel(problem.elementTypeIndices);
        
        problem.subelementNodeIndices = problem.elementNodeIndices;
        problem.subelementTopologies = problem.elementTopologies;
        problem.subelementTypeIndices = problem.elementTypeIndices;

        problem.elementConnections = cell(1,nElements);
        for iElement = 1:nElements
            problem.elementConnections{1} = { { iElement 1 } };
        end
    elseif problem.dimension == 2
        
        % find existing edges
        nElements = numel(problem.elementTypeIndices);
        nEdges = 0;
        edges = { };
        for iElement = 1:nElements
            if problem.elementTopologies(iElement) == 1
                nEdges = nEdges + 1;
                edges{nEdges} = problem.elementNodeIndices{iElement}; %#ok
            end
        end
        
        nExistingEdges = nEdges;
        
        % create missing edges
        for iElement = 1:nElements
            if problem.elementTopologies(iElement) == 2
                indices = problem.elementNodeIndices{iElement};
                
                edgeIndices = [indices(1), indices(2)];
                index = getIndexOfEdge(edges, edgeIndices);
                if index > nEdges
                    nEdges = nEdges + 1;
                    edges{nEdges} = edgeIndices; %#ok
                end
                
                edgeIndices = [indices(3), indices(4)];
                index = getIndexOfEdge(edges, edgeIndices);
                if index > nEdges
                    nEdges = nEdges + 1;
                    edges{nEdges} = edgeIndices; %#ok
                end
                
                edgeIndices = [indices(1), indices(3)];
                index = getIndexOfEdge(edges, edgeIndices);
                if index > nEdges
                    nEdges = nEdges + 1;
                    edges{nEdges} = edgeIndices; %#ok
                end
                
                edgeIndices = [indices(2), indices(4)];
                index = getIndexOfEdge(edges, edgeIndices);
                if index > nEdges
                    nEdges = nEdges + 1;
                    edges{nEdges} = edgeIndices; %#ok
                end
            end
        end
        
        newEdges = edges(nExistingEdges+1:nEdges);
        newTopologies = ones(1, nEdges-nExistingEdges);
        newTypes = 2*ones(1, nEdges-nExistingEdges); % assuming 2!
        
        % create subelements
        problem.subelementNodeIndices = [ problem.elementNodeIndices; newEdges' ];
        problem.subelementTopologies = [ problem.elementTopologies, newTopologies ];
        problem.subelementTypeIndices = [ problem.elementTypeIndices, newTypes ];

    else
        
        disp('ERROR! poCreateSubElements can only handle one dimension.');
    end

end

function edgeIndex = getIndexOfEdge(edges, edgeIndices)

    
    nEdges = numel(edges);
    edgeIndex = nEdges + 1;
    for iEdge = 1:nEdges
        edge = edges{iEdge};
        if edge(1)==edgeIndices(1) && edge(2) == edgeIndices(2)
            edgeIndex = iEdge;
            return;
        end
        if edge(2)==edgeIndices(1) && edge(1) == edgeIndices(2)
            edgeIndex = iEdge;
            return;
        end
        
    end

end

