function [ shapeIndices ] = eoGetNonZeroInternalShapeIndices( problem, elementIndex)
% eoGetNodalShapeIndices Gets the indices of the nodal shape functions
% within the overall shape function array and the corresponding global node
% indices.

    % get coinciding subelements
    nonZeroSubElementIndices = eoGetCoincidingSubelements( problem, elementIndex );

    % get connections to subelements
    connections = problem.elementConnections{elementIndex};
    nConnections = numel(connections);
    
    % gather subelement information
    nSubelementNonZeroInternalShapes = zeros(nConnections,1);
    nSubelementNonZeroNodalShapes = zeros(nConnections,1);
    nSubelementInternalShapes = zeros(nConnections,1);
    nSubelementNodalShapes = zeros(nConnections,1);
    
    for iConnection = 1:nConnections
        subelementIndex = connections{iConnection}{1};
        subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
        
        nSubelementInternalShapes(iConnection) = problem.subelementTypes{subelementTypeIndex}.numberOfInternalShapes;
        nSubelementNodalShapes(iConnection) = nSubelementNonZeroInternalShapes(iConnection) + problem.subelementTypes{subelementTypeIndex}.numberOfNodalShapes;
            
        if ismember(iConnection, nonZeroSubElementIndices)
           nSubelementNonZeroInternalShapes(iConnection) = nSubelementInternalShapes(iConnection);
           nSubelementNonZeroNodalShapes(iConnection) = nSubelementNodalShapes(iConnection);
        end
    end

    % create element information
    nInternalShapes = sum(nSubelementNonZeroInternalShapes);
    shapeIndices = zeros(nInternalShapes,1);
    
    shapeIndex = 0;
    internalShapeCounter = 0;
    for iConnection = 1:nConnections
        
        nInternalShapes = nSubelementNonZeroInternalShapes(iConnection);
        indices = (internalShapeCounter + 1):(internalShapeCounter + nInternalShapes);
        shapeIndices(indices) = shapeIndex+1:shapeIndex+nInternalShapes;
               
        internalShapeCounter = internalShapeCounter + nInternalShapes;
        
        nShapes = nSubelementNodalShapes(iConnection) + nSubelementInternalShapes(iConnection);
        shapeIndex = shapeIndex + nShapes;
    end

    
end

