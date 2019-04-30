function [ allUeDynamic ] = goDisassembleDynamicVector(problem, UDynamic, allLe)
% disassembleDynamicGlobalSolutionVector Disassembles a dynamic global (dense) vector.
    
    % get number of time steps
    [ nTimeSteps ] = problem.dynamics.nTimeSteps;
    
    % create allUe for every time step
    allUeDynamic = cell(nTimeSteps,1);
    
    for i = 1:nTimeSteps
        UDynamicAtCurrentTimeStep = UDynamic(:,i);
        allUeDynamic{i} = goDisassembleVector( UDynamicAtCurrentTimeStep, allLe );
    end
end