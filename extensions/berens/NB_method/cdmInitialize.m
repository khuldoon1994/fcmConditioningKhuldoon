function [ u, uDot, uDdot ] = cdmInitialize(problem, u0, u0Dot, u0Ddot)
% NOTHING WAS CHANGED to cdmInitialize 

    %calculate initial values for Central Difference Method
    % u0        =       u(0)
    % u0Dot     =       d/dt u(0)
    % u0Ddot    =       d^2/dt^2 u(0)
    %
    % uMinus1   =       u(-1)
    % u         =       u(0)
    % uDot      =       d/dt u(0)
    % uDdot     =       d^2/dt^2 u(0)
    
    
    %parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    %integration constant
    a3 = (deltaT^2)/2;
    
    %initial values
    u = u0;
    uDot = u0Dot;
    uDdot = u0Ddot;
end