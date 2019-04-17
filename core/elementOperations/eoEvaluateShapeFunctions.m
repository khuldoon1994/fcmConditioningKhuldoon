function [ shapeFunctions ] = eoEvaluateShapeFunctions( problem, elementIndex, localCoordinates)
%eoEvaluateShapeFunctions Evaluates the shape functions of an element by
% evaluating and concatenating the shape functions of all subelements 

    % connections to subelements for this element
    connections = problem.elementConnections{elementIndex};
    nConnections = numel(connections);

    % storage for subelement shape functions
    subelementShapes = cell(nConnections,1);
    
    % create full coordinates (fill up with 1)
    r = moMakeFull(localCoordinates,problem.dimension,1);
    
    % loop through subelements
    nShapes = 0;
    for iConnection=1:nConnections
        
        % get subelement shape function evaluator
        subelementIndex = connections{iConnection}{1};
        subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
        shapeFunctionEvaluator = problem.subelementTypes{subelementTypeIndex}.shapeFunctionEvaluator;
        
        % map element coordinates to subelement coordinates
        transformation = connections{iConnection}{2};
        subelementCoordinates = transformation * r;
        
        % evaluate subelement shape functions
        subelementShapes{iConnection} = shapeFunctionEvaluator(problem, subelementIndex, subelementCoordinates, 0);
        
        % increment counter
        nShapes = nShapes + numel(subelementShapes{iConnection});
    end
    
    % concatenate subelement shape functions
    shapeFunctions = zeros(1,nShapes);
    offset = 0;
    for iConnection=1:nConnections
        nSubelementShapes = numel(subelementShapes{iConnection});
        shapeFunctions(offset+1:offset+nSubelementShapes) = subelementShapes{iConnection};
        offset = offset + nSubelementShapes;
    end
    
    
end

