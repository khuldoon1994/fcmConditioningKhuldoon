function [ Me, Ke, Fe ] = dynamicPointMassSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % structure
    mass = problem.elementTypes{elementTypeIndex}.mass;
    
    % single dof "matrices"
    Ke = zeros(nDof,nDof);
    Me = mass*eye(nDof);
    Fe = eoEvaluateTotalLoad(problem, elementIndex, []);
    
end