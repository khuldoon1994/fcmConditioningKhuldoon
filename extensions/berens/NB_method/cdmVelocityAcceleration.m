function [ uDot, uDdot ] = cdmVelocityAcceleration(problem, uNew, u, uOld)
    %calculate velocity and acceleration for Central Difference Method
    % uNew      =       u(n+1)
    % u         =       u(n)
    % uOld      =       u(n-1)
    %
    % uDot      =       d/dt u(n)
    % uDdot     =       d^2/dt^2 u(n)
    
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % integration constants
    a0 = 1/(deltaT^2);
    a1 = 1/(2*deltaT);
    a2 = 2/(deltaT^2);
    
    % velocity and acceleration
    uDot = a1*(uNew - uOld);
    uDdot = a0*(uNew - 2*u + uOld);
    
end