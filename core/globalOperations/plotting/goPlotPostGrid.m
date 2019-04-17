function goPlotPostGrid( problem, postGrid, fig )

    figure(fig);
    hold on;

    for iPostGridCell=1:numel(postGrid)
      
      topology = postGrid{iPostGridCell}{1};
      nodesGlobal = postGrid{iPostGridCell}{2};
      elementIndex = postGrid{iPostGridCell}{3};
      nodesLocal = postGrid{iPostGridCell}{4};
            
      goPlotBasicCell(problem, topology, nodesGlobal, nodesGlobal, nodesGlobal*0);
    
    end

    colorbar
end
