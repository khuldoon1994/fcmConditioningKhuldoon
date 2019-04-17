function [ nodeIndices, shapeIndices ] = eoGetNodalShapeIndices( problem, elementIndex)
% eoGetNodalShapeIndices Gets the indices of the nodal shape functions
% within the overall shape function array and the corresponding global node
% indices.

    % get connections to subelements
    connections = problem.elementConnections{elementIndex};
    nConnections = numel(connections);
    
    % gather subelement information
    nSubelementInternalShapes = zeros(nConnections,1);
    nSubelementNodalShapes = zeros(nConnections,1);
    subelementNodeIndices = cell(nConnections,1);

    for iConnection = 1:nConnections
        subelementIndex = connections{iConnection}{1};
        subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
        
        subelementNodeIndices{iConnection} =  problem.subelementNodeIndices{subelementIndex};
        nSubelementNodalShapes(iConnection) = problem.subelementTypes{subelementTypeIndex}.numberOfNodalShapes;
        nSubelementInternalShapes(iConnection) = problem.subelementTypes{subelementTypeIndex}.numberOfInternalShapes;
   
        if nSubelementNodalShapes(iConnection) == 0
            subelementNodeIndices{iConnection} = [ ];
        end
    end

    % create element information
    nNodalShapes = sum(nSubelementNodalShapes);
    nodeIndices = zeros(nNodalShapes,1);
    shapeIndices = zeros(nNodalShapes,1);
    
    shapeIndex = 0;
    nodalShapeCounter = 0;
    for iConnection = 1:nConnections
                
        nNodalShapes = nSubelementNodalShapes(iConnection);
        nShapes = nSubelementInternalShapes(iConnection) + nNodalShapes;
                
        indices = (nodalShapeCounter + 1):(nodalShapeCounter + nNodalShapes);
        
        nodeIndices(indices) = subelementNodeIndices{iConnection};
        shapeIndices(indices) = shapeIndex+1:shapeIndex+nNodalShapes;
        
        nodalShapeCounter = nodalShapeCounter + nNodalShapes;
        shapeIndex = shapeIndex + nShapes;
    end

    
end

