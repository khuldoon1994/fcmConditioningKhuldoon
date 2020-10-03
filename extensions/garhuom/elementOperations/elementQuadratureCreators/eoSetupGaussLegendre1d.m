function problem = eoSetupGaussLegendre1d( problem, elementIndex )
%eoSetupGaussLegendre1d Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};
orderOfQuadrature = elementType.quadratureType.order;

pq = orderOfQuadrature;
ng = ceil( (pq+1)/2 );

[points, weights] = gaussLegendre1d( ng );

problem.elementQuadratures{elementIndex}.points = points;
problem.elementQuadratures{elementIndex}.weights = weights;


end

