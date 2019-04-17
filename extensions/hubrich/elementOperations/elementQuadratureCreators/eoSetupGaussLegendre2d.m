function problem = eoSetupGaussLegendre2d( problem, elementIndex )
%eoSetupGaussLegendre1d Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};
orderOfQuadrature = elementType.quadratureType.order;

pq = orderOfQuadrature;
ng1d = ceil( (pq+1)/2 );
[xg1d, wg1d] = gaussLegendre1d( ng1d );
[X, Y] = meshgrid(xg1d, xg1d);

xg(1,:) = X(:)';
xg(2,:) = Y(:)';
wg = kron(wg1d,wg1d);



problem.elementQuadratures{elementIndex}.points = xg;
problem.elementQuadratures{elementIndex}.weights = wg;


end

