function [ FEff ] = twEffectiveSystemForceVector(problem, D, K, F, vNew, uNew)
% before: cdmEffectiveSystemForceVector_2(problem, M, D, K, F, u, uOld)

    %calculate effective force vector for the TW Method
    % vNew      =       udot(n+1)
    % uNew      =       u(n+1)
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
        
    FEff = F - D*vNew - K*uNew; 
    
    % add penalty constraints to effective force vector
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    FEff = FEff + Fp;
    
end