function [ shapeFunctions ] = eoEvaluateShapeFunctionLocalDerivatives( problem, elementIndex, localCoordinates)
%EVALUATESHAPEFUNCTIONS Summary of this function goes here
%   Detailed explanation goes here

    elementConnections = problem.elementConnections{elementIndex};
    nConnections = numel(elementConnections);

    subelementShapes = cell(nConnections,1);
    nShapes = 0;
    for iConnection=1:nConnections
        
        subelementIndex = elementConnections{iConnection}{1};
        subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
        shapeFunctionEvaluator = problem.subelementTypes{subelementTypeIndex}.shapeFunctionEvaluator;
        
        transformation = elementConnections{iConnection}{2};
        subelementCoordinates = transformation * localCoordinates;
        
        subelementShapes{iConnection} = ...
            shapeFunctionEvaluator(problem, subelementIndex, subelementCoordinates, 1);
        
        nShapes = nShapes + size(subelementShapes{iConnection},2);
    end
    
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    localDimension = problem.elementTypes{elementTypeIndex}.localDimension;
    
    shapeFunctions = zeros(localDimension,nShapes);
    offset = 0;
    for iConnection=1:nConnections
        nSubelementShapes = size(subelementShapes{iConnection},2);
        transformation = elementConnections{iConnection}{2};
        shapeFunctions(:,offset+1:offset+nSubelementShapes) = transformation' * subelementShapes{iConnection};
        offset = offset + nSubelementShapes;
    end
    
    
end