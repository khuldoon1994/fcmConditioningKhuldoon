function [UNewDynamic_2] = pmDisplacement_2(problem, UNewDynamic_1, VNewDynamic_1, ANewDynamic_1, p_nb, eta)

    %calculate displacement for NB method for the first sub timestep
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % displacement
    UNewDynamic_2 = UNewDynamic_1 + ((1-p_nb)*deltaT)*VNewDynamic_1 + (eta/2)*((1-p_nb)*deltaT)^2 * ANewDynamic_1;
   
    end