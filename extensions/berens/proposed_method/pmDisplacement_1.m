function [UNewDynamic_1] = pmDisplacement_1(problem, UDynamic, VDynamic, ADynamic, p_nb, eta);

    %calculate displacement for NB method for the first sub timestep
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % displacement
    UNewDynamic_1 = UDynamic + (p_nb*deltaT)*VDynamic + (eta/2)*(p_nb*deltaT)^2*ADynamic; 
        
end