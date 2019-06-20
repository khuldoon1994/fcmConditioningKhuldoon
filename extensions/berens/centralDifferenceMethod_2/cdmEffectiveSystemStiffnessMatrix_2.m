function [ KEff ] = cdmEffectiveSystemStiffnessMatrix_2(problem, M, D, K)
    %calculate effective stiffness matrix for the Central Difference Method
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % integration constants
    a0 = 1/(deltaT^2);
    a1 = 1/(2*deltaT);
    a2 = 2/(deltaT^2);
    
    % effective stiffness matrix
    KEff = (a0*M + a1*D)*deltaT^2;
    % KEff = M + 0.5*deltaT*D; % already multiplied with deltaT^2
    
    % add penalty constraints to effective stiffness matrix
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    KEff = KEff + Kp;
    
end