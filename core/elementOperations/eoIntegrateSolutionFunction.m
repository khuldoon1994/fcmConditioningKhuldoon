function [ res ] = eoIntegrateSolutionFunction( problem, elementIndex, Ue, integrand )
% eoIntegrateFunction Integrates the solution dependend integrand over the 
% element's domain

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
        res = res + integrand( problem, elementIndex, points(:,i), jacobian, detJ, Ue ) * detJ * weights(i);
        
    end

end

