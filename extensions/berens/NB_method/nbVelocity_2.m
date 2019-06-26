function [ VNewDynamic_2 ] = nbVelocity_2(problem, VNewDynamic_1, ADynamic, ANewDynamic_1,ANewDynamic_2, p_nb);

    % calculate velocity for NB method 
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % calculate coefficients 
    q1   = (1 - 2*p_nb)/(2*p_nb*(1 - p_nb)); 
    q2   = 0.5 - p_nb*q1; 
    q0   = -q1 - q2 + 0.5; 
    a0   = q0*(1 - p_nb)* deltaT; 
    a1   = (0.5 + q1)*(1 - p_nb)*deltaT; 
    a2   = q2*(1 - p_nb)*deltaT; 
    
    % velocity 
    VNewDynamic_2 = VNewDynamic_1 + a0*ADynamic + a1*ANewDynamic_1 + a2*ANewDynamic_2 ; 
    
end