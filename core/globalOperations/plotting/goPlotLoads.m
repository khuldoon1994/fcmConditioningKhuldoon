function goPlotLoads( problem, fig, factor )

    if(nargin < 3)
       factor = 1.0;
    end

    figure(fig);
    hold on;
    
    nElements = numel(problem.elementTypeIndices);
    for iElement=1:nElements
      
      if numel(problem.elementLoads{iElement})>0

        elementTypeIndex = problem.elementTypeIndices(iElement);
        elementTopology = problem.elementTopologies(iElement);
        
        %problem.elementTypes{elementTypeIndex}.elementPlotter(problem, iElement);
      
        if elementTopology == 1 % line
            nPoints=10;
            r = linspace(-1, 1, nPoints);
            for i=1:nPoints
                position = problem.elementTypes{elementTypeIndex}.mappingEvaluator(problem, iElement,r(i));
                position = moMakeFull(position,3,0);
                load = eoEvaluateTotalLoad(problem, iElement, r(i));
                load = moMakeFull(load, 3, 0)*factor;
                quiver3(position(1), position(2), position(3), load(1), load(2), load(3),'Color','red','LineWidth',2,'MaxHeadSize',1);
            end
        elseif elementTopology == 5 % point
            position = problem.nodes(:, problem.elementNodeIndices{iElement});
            position = moMakeFull(position, 3, 0);
            load = eoEvaluateTotalLoad(problem, iElement, []);
            load = moMakeFull(load, 3, 0)*factor;
            quiver3(position(1), position(2), position(3), load(1), load(2), load(3),'Color','red','LineWidth',2,'MaxHeadSize',1);
        else
            disp('ERROR! Loads can only be plottet for lines so far.');
        end
        
      end

    end
    
end