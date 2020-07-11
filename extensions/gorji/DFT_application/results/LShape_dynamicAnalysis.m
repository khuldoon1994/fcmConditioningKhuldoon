
% load data
load('setup/LShape_data.mat');
load('setup/LShape_data_dynamic.mat');
load('computation/LShape_results_DFT.mat');


%% dynamic analysis
index = find(uQy_DFT == min(uQy_DFT));              % 321
Ui = uDFT(:,index);
ti = tDFT(index);

[ allUe ] = goDisassembleVector( Ui, allLe );

% post processing
figure();
iFig = get(gcf,'Number');
postGridCells = goCreatePostGrid( problem, 0 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, iFig);
axis equal;
title(['t = ',num2str(ti),' s']);


% save figure
saveas(gcf,'results/results_LShape_dynamic.jpg');



%% Animation

clear Frames
Frames(N+1) = struct('cdata',[],'colormap',[]);

% post processing
figure('units','normalized','position',[0 0 1 1]);
postGridCells = goCreatePostGrid( problem, 0 );

postGrid = postGridCells;
solutionCalculator = @eoEvaluateSolution;
deformationCalculator = @eoEvaluateSolution;

for i = 1:N+1
    if(i ~= N+1)
        Ui = uDFT(:,i);
        ti = tDFT(i);
    else
        Ui = uDFT(:,1);
        ti = tDFT(N) + tDFT(2);
        
    end
    [ allUe ] = goDisassembleVector( Ui, allLe );
    
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
    axis equal;
    title(['t = ',num2str(ti),' s']);
    % without colorbar it is much quicker
%     colorbar;
    
    % update figure
    drawnow limitrate;
    pause(0.01);
    hold off;
    
    Frames(i) = getframe(gcf);
end

%% save frames
save('results/LShape_frame_data.mat', 'Frames');





