function [ FEff_1 ] = nbEffectiveSystemForceVector_1(problem, D, K, F, VDynamic, ADynamic, UNewDynamic_1, p_nb)
   
    %calculate effective force vector for the first subtimestep
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    FEff_1 = F - D*(VDynamic + (p_nb*deltaT)*ADynamic) - K*UNewDynamic_1; 
    
    % add penalty constraints to effective force vector
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    FEff_1 = FEff_1 + Fp;
   
end