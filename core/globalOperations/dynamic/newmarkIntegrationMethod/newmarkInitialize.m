function [ u, uDot, uDdot ] = newmarkInitialize(problem, u0, u0Dot, u0Ddot)
    %calculate initial values for Newmark Integration Method
    % u0        =       u(0)
    % u0Dot     =       d/dt u(0)
    % u0Ddot    =       d^2/dt^2 u(0)
    %
    % u         =       u(0)
    % uDot      =       d/dt u(0)
    % uDdot     =       d^2/dt^2 u(0)
    
    %initial values
    u = u0;
    uDot = u0Dot;
    uDdot = u0Ddot;
    
end