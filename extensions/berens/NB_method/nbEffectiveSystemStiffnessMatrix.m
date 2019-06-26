function [ KEff ] = nbEffectiveSystemStiffnessMatrix(problem, M)
    %calculate effective stiffness matrix for the Central Difference Method
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % effective stiffness matrix
    KEff = M;
      
    % add penalty constraints to effective stiffness matrix
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    KEff = KEff + Kp;
    
end