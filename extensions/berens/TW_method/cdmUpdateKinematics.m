function [ u, uOld ] = cdmUpdateKinematics(uNew, u)
    %update kinematic quantities for Central Difference Method
    % uNew      =       u(n+1)
    % u         =       u(n)
    %
    % update: n --> n+1
    % u         =       u(n)
    % uOld      =       u(n-1)
    
    
    uOld = u;
    u = uNew;
    
end