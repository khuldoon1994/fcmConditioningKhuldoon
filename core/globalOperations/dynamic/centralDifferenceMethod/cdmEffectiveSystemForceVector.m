function [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, u, uOld)
    %calculate effective force vector for the Central Difference Method
    % u         =       u(n)
    % uOld      =       u(n-1)
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % integration constants
    a0 = 1/(deltaT^2);
    a1 = 1/(2*deltaT);
    a2 = 2/(deltaT^2);
    
    % effective force vector
    FEff = F - (K-a2*M)*u  - (a0*M-a1*D)*uOld;
    
    % add penalty constraints to effective force vector
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    FEff = FEff + Fp;
    
end