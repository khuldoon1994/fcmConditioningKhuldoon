function [ points, weights ] = predefinedQuadrature( problem, elementIndex )
%predefinedQuadrature Returns the quadrature points points and weights, that
% where stored in the problem data structure previously, possibly by
% calling poSetupQuadraturePoints.
% Use this quadrature point getter in combination with a quadrature rule,
% for which the computation of the quadrature points is expensive and
% should only be performed once.

    points = problem.elementQuadratures{elementIndex}.points;
    weights = problem.elementQuadratures{elementIndex}.weights;
    
end

