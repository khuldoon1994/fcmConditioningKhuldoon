function [UNewDynamic_1] = nbDisplacement_1(problem, UDynamic, VDynamic, ADynamic, p_nb)

    %calculate displacement for NB method for the first sub timestep
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % displacement
    UNewDynamic_1 = UDynamic + (p_nb*deltaT)*VDynamic + 0.5*(p_nb*deltaT)^2*ADynamic; 
    
    
end