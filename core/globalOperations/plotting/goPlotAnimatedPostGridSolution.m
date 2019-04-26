function goPlotAnimatedPostGridSolution( problem, allUeDynamic, postGrid, solutionCalculator, deformationCalculator, fig )

    figure(fig);
    % set(fig,'defaultLegendAutoUpdate','off');
    timeVector = goGetTimeVector(problem);
    nTimeSteps = problem.dynamics.nTimeSteps;
    
    for timeStep = 1:nTimeSteps
        allUe = allUeDynamic{timeStep};
        delete(gca);
        hold on;
        grid on;
        tic();
        % plot deformed structure
        for iPostGridCell=1:numel(postGrid)
        
          topology = postGrid{iPostGridCell}{1};
          nodesGlobal = postGrid{iPostGridCell}{2};
          cellIndex = postGrid{iPostGridCell}{3};
          nodesLocal = postGrid{iPostGridCell}{4};
        
          solution = solutionCalculator(problem, cellIndex, allUe{cellIndex}, nodesLocal);
          deformation = deformationCalculator(problem, cellIndex, allUe{cellIndex}, nodesLocal);      
        
          goPlotBasicCell(problem, topology, nodesGlobal, solution, deformation);
        end
        toc()
        axis equal
        title(['Displacement solution, time = ', num2str(timeVector(timeStep))]);
        % without colorbar it is much quicker
        %colorbar;
        pause(0.01);
        hold off;
    end
    
end
