function [uNew] = cdmDisplacement_2(problem, u, uDot, uDdot)

    %calculate displacement for Central Difference Method
    % uNew      =                u(n+1)
    % u         =                u(n)
    % uDot      =       d/dt     u(n)
    % uDdot     =       d^2/dt^2 u(n)
    
    
    % parameter = {deltaT}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    
    % displacement
    uNew = u + deltaT*uDot + 0.5*(deltaT^2)*uDdot; 
    
end