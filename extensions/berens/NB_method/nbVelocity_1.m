function [ VNewDynamic_1 ] = nbVelocity_1(problem, VDynamic, ADynamic, ANewDynamic_1, p_nb);

    %calculate velocity for NB method 

    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % velocity 
   VNewDynamic_1 = VDynamic + 0.5*(p_nb*deltaT)*(ADynamic + ANewDynamic_1); 
    
end