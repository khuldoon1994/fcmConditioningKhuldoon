function [ problem ] = poInitializeDynamicProblem(problem)
    
    %standard parameters
    standardTimeIntegration = 'Central Difference';
    standardLumping = 'No Lumping';
    standardTStart = 0;
    standardTStop = 10;
    standardNTimeSteps = 51;
    standardDynamicSolver = @cdmDynamicSolver;

    if(~isfield(problem, 'dynamics'))
    % if structure "dynamics" not defined
        problem.dynamics.timeIntegration = standardTimeIntegration;
        problem.dynamics.lumping = standardLumping;
        problem.dynamics.tStart = standardTStart;
        problem.dynamics.tStop = standardTStop;
        problem.dynamics.nTimeSteps = standardNTimeSteps;
%         problem.dynamics.parameter = standardParameter;
        problem.dynamics.dynamicSolver = standardDynamicSolver;
        warning(['WARNING! No dynamics defined. Assume ', ...
                        standardTimeIntegration, ', ', ...
                        standardLumping, ', ', ...
                        num2str(standardTStart), ', ', ...
                        num2str(standardTStop), ', ', ...
                        num2str(standardNTimeSteps), ', ', ...
                        func2str(standardDynamicSolver)]);
    else
    % if structure "dynamics" defined, but fields not defined
        % if field "timeIntegration" not defined
        if(~isfield(problem.dynamics, 'timeIntegration'))
            problem.dynamics.timeIntegration = standardTimeIntegration;
            warning(['WARNING! No dynamics.timeIntegration defined. Assume ', standardTimeIntegration]);
        end
        % if field "lumping" not defined
        if(~isfield(problem.dynamics, 'lumping'))
            problem.dynamics.lumping = standardLumping;
            warning(['WARNING! No dynamics.lumping defined. Assume ', standardLumping]);
        end
        % if field "tStart" not defined
        if(~isfield(problem.dynamics, 'tStart'))
            problem.dynamics.tStart = standardTStart;
            warning(['WARNING! No dynamics.tStart defined. Assume ', num2str(standardTStart)]);
        end
        % if field "tStop" not defined
        if(~isfield(problem.dynamics, 'tStop'))
            problem.dynamics.tStop = standardTStop;
            warning(['WARNING! No dynamics.tStop defined. Assume ', num2str(standardTStop)]);
        end
        % if field "nTimeSteps" not defined
        if(~isfield(problem.dynamics, 'nTimeSteps'))
            problem.dynamics.nTimeSteps = standardNTimeSteps;
            warning(['WARNING! No dynamics.nTimeSteps defined. Assume ', num2str(standardNTimeSteps)]);
        end
        % if field "dynamicSolver" not defined
        if(~isfield(problem.dynamics, 'dynamicSolver'))
            problem.dynamics.dynamicSolver = standardDynamicSolver;
            % no warning
        end
    end 
        
    % calculate sampling time "deltaT"
    deltaT = goGetSamplingTime(problem);
    
    % attach dynamicSolver to the "dynamics" structure
    if(strcmp(problem.dynamics.timeIntegration, 'Central Difference'))
        problem.dynamics.dynamicSolver = @cdmDynamicSolver;
    elseif(strcmp(problem.dynamics.timeIntegration, 'Newmark Integration'))
        problem.dynamics.dynamicSolver = @newmarkDynamicSolver;
    end
    
    % apply sampling time to structure "dynamics"
    if(strcmp(problem.dynamics.timeIntegration, 'Central Difference'))
        problem.dynamics.parameter = {deltaT};
    elseif(strcmp(problem.dynamics.timeIntegration, 'Newmark Integration'))
        problem.dynamics.parameter = {deltaT, 0.25, 0.5};
    else
        error('timeIntegration is not correct, choose either Central Difference or Newmark Integration');
    end
    
end

