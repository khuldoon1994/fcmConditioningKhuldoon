function [ uDotNew, uDdotNew ] = newmarkVelocityAcceleration(problem, uNew, u, uDot, uDdot)
    %calculate velocity and acceleration for Newmark Integration Method
    % uNew      =       u(n+1)
    % u         =       u(n)
    % uDot      =       d/dt u(n)
    % uDdot     =       d^2/dt^2 u(n)
    %
    % uDotNew   =       d/dt u(n+1)
    % uDdotNew  =       d^2/dt^2 u(n+1)
    
    
    % parameter = {deltaT, alpha, delta}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    alpha = parameter{2};
    delta = parameter{3};
    
    % integration constants
    a0 = 1/(alpha*deltaT^2);
    a1 = delta/(alpha*deltaT);
    a2 = 1/(alpha*deltaT);
    a3 = 1/(2*alpha)-1;
    a4 = delta/alpha-1;
    a5 = deltaT/2*(delta/alpha-2);
    a6 = deltaT*(1-delta);
    a7 = delta*deltaT;
    
    % velocity and acceleration    
    uDdotNew = a0*(uNew - u) - a2*uDot - a3*uDdot;
    uDotNew = uDot + a6*uDdot + a7*uDdotNew;
    
end