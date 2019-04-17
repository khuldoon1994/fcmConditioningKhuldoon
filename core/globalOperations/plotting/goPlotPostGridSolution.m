function goPlotPostGridSolution( problem, allUe, postGrid, solutionCalculator, deformationCalculator, fig )

    figure(fig);
    hold on;

    for iPostGridCell=1:numel(postGrid)
      
      topology = postGrid{iPostGridCell}{1};
      nodesGlobal = postGrid{iPostGridCell}{2};
      cellIndex = postGrid{iPostGridCell}{3};
      nodesLocal = postGrid{iPostGridCell}{4};
      
      solution = solutionCalculator(problem, cellIndex, allUe{cellIndex}, nodesLocal);
      deformation = deformationCalculator(problem, cellIndex, allUe{cellIndex}, nodesLocal);      
      
      goPlotBasicCell(problem, topology, nodesGlobal, solution, deformation);
    
    end

    colorbar
    
end
