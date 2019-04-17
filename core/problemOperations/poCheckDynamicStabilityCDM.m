function [ deltaT, deltaTCrit ] = poCheckDynamicStabilityCDM(problem, M, K)
    % stability check for the Central Difference Method
    
    if nargin < 2
        % create system matrices
        [ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );
        
        % assemble
        M = goAssembleMatrix(allMe, allLe);
        K = goAssembleMatrix(allKe, allLe);
    end
    
    if(~strcmp(problem.dynamics.timeIntegration, 'Central Difference'))
        warning('Stability Check is defined for Central Difference, change problem.dynamics.timeIntegration');
    end
    
    % calculate sampling time
    deltaT = goGetSamplingTime(problem);
    % calculate critical sampling time
    deltaTCrit = cdmCriticalSamplingTime(M, K);
    
    % check if time integration will be stable
    disp(['sampling time deltaT = ', num2str(deltaT), ' sec']);
    disp(['critical sampling time deltaTCrit = ', num2str(deltaTCrit), ' sec']);
    if(deltaT > deltaTCrit)
        warning(['sampling time deltaT must be lower than critical sampling time deltaTCrit = ', ...
            num2str(deltaTCrit), ' sec, increase problem.dynamics.nTimeSteps']);
    end
end

