function [uNew] = twDisplacement(problem, u, uDot, uDdot)

    %calculate displacement for Central Difference Method
    % uNew      =                u(n+1)
    % u         =                u(n)
    % uDot      =       d/dt     u(n)
    % uDdot     =       d^2/dt^2 u(n)
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    phi = 0.5; 
    % displacement
    uNew = u + deltaT*uDot + phi*(deltaT^2)*uDdot; 
    
end