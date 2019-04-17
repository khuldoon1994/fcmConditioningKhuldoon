function [ res ] = eoIntegrateFunction( problem, elementIndex, integrand )
%eoIntegrateFunction Integrates the integrand over the element's domain

    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    quadraturePointGetter = problem.elementTypes{elementTypeIndex}.quadraturePointGetter;
    
    % create quadrature points
    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
    nPoints = numel(weights);

    % loop over quadrature points
    res=0;
    for i=1:nPoints
        
        jacobian = eoEvaluateJacobian(problem,elementIndex,points(:,i));
        detJ = det(jacobian);
        res = res + integrand( problem, elementIndex, points(:,i), jacobian, detJ ) * detJ * weights(i);
        
    end

end

