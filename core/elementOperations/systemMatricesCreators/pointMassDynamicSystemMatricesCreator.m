function [ Me, De, Ke, Fe ] = pointMassDynamicSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % single dof "matrices"
    Ke = zeros(2,2);
    De = zeros(2,2);
    Me = 0.5*eye(2)*problem.elementTypes{elementTypeIndex}.mass;
    Fe = eoEvaluateTotalLoad(problem, elementIndex, []);
    
end