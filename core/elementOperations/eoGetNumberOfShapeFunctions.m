function [ nShapes ] = eoGetNumberOfShapeFunctions(problem,elementIndex)
% eoGetNumberOfShapeFunctions Gets the number of shape functions for an
% element.

    elementConnections = problem.elementConnections{elementIndex};
    nConnections = numel(elementConnections);

    nShapes = 0;
    for iConnection=1:nConnections
        subelementIndex = elementConnections{iConnection}{1};
        nShapes = nShapes + seoGetNumberOfShapeFunctions(problem,subelementIndex);
    end
  
end