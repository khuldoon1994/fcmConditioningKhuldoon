function goPlotAnimatedPostGridSolution( problem, allUeDynamic, postGrid, solutionCalculator, deformationCalculator, fig )

    figure(fig);
    % set(fig,'defaultLegendAutoUpdate','off');
    timeVector = goGetTimeVector(problem);
    nTimeSteps = problem.dynamics.nTimeSteps;
    
    for timeStep = 1:nTimeSteps
        allUe = allUeDynamic{timeStep};
        % dummy plot to delete the current figure
        plot(0,0);
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
        toc();
        axis equal
        title(['Displacement solution, time = ', num2str(timeVector(timeStep))]);
        colorbar;
        
        % update figure
        drawnow();
        hold off;
    end
    
end
