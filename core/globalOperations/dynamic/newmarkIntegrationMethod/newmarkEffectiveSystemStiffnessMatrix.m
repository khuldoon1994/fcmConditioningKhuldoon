function [ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K)
    %calculate effective stiffness matrix for the Newmark Integration Method
    
    % parameter = {deltaT, alpha, delta}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    alpha = parameter{2};
    delta = parameter{3};
    
    % integration constants
    a0 = 1/(alpha*deltaT^2);
    a1 = delta/(alpha*deltaT);
    a2 = 1/(alpha*deltaT);
    a3 = 1/(2*alpha)-1;
    a4 = delta/alpha-1;
    a5 = deltaT/2*(delta/alpha-2);
    a6 = deltaT*(1-delta);
    a7 = delta*deltaT;
    
    % effective stiffness matrix
    KEff = K + a0*M + a1*D;
    
    % add penalty constraints to effective stiffness matrix
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    KEff = KEff + Kp;
    
end