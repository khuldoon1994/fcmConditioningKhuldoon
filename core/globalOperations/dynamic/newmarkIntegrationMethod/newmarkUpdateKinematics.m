function [ u, uDot, uDdot ] = newmarkUpdateKinematics(uNew, uDotNew, uDdotNew)
    %update kinematic quantities for Newmark Integration Method
    % uNew      =       u(n+1)
    % uDotNew   =       d/dt u(n+1)
    % uDdotNew  =       d^2/dt^2 u(n+1)
    %
    % update: n --> n+1
    % u         =       u(n)
    % uDot      =       d/dt u(n)
    % uDdot     =       d^2/dt^2 u(n)
    
    
    u = uNew;
    uDot = uDotNew;
    uDdot = uDdotNew;
    
end