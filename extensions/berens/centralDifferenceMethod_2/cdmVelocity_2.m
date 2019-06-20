function [ uNewDot ] = cdmVelocity_2(problem, uDot, uDdot, uNewDdot)
    %calculate velocity and acceleration for Central Difference Method

    % u         =       u(n)
    % uDot      =       d/dt     u(n)   % VDynamic 
    % uDdot     =       d^2/dt^2 u(n)   % ADynamic 

    % uNewDot   =       d/dt     u(n+1)  % VNewDynamic
    % uNewDdot  =       d^2/dt^2 u(n+1)  % ANewDynamic 
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % velocity 
    uNewDot = uDot + 0.5*deltaT*(uDdot + uNewDdot); 
    
end