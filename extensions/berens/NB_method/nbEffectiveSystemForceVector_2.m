function [ FEff_2 ] = nbEffectiveSystemForceVector_2(problem, D, K, F, VNewDynamic_1, ANewDynamic_1, UNewDynamic_2, p_nb)
   
    %calculate effective force vector for the second subtimestep
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    FEff_2 = F - D*(VNewDynamic_1 + ((1-p_nb)*deltaT)*ANewDynamic_1) - K*UNewDynamic_2; 
    
    % add penalty constraints to effective force vector
    [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
    FEff_2 = FEff_2 + Fp;
    
end