
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
figure('units','normalized','position',[0 0 1 1]);
iFig = get(gcf,'Number');
postGridCells = goCreatePostGrid( problem, 0 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, iFig);
axis equal;
title(['t = ',num2str(ti),' s'],'FontSize',20);

% plot excitation
axes('Position', [.65 .15 .16 .16]);
plot(tDFT,f(tDFT),'k','LineWidth',1.8);
hold on
grid on
plot(ti,f(ti),'ro','LineWidth',2.0,'Markersize',9);



% save figure
saveas(gcf,'results/results_LShape_dynamic.jpg');



%% Animation

clear Frames
Frames(N+1) = struct('cdata',[],'colormap',[]);

% post processing
h1 = figure('units','normalized','position',[0 0 1 1]);
ax1 = axes('Position',[0.1 0.1 0.8 0.8]);
ax2 = axes('Position', [.65 .15 .16 .16]);
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
    set(h1,'CurrentAxes',ax1);
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
%     axis equal;
%     axis([-1.17 4.17 0 3]);
    axis([-1.437 4.437 0 3.3]);
    title(['t = ',num2str(ti),' s'],'FontSize',20);
    % without colorbar it is much quicker
%     colorbar;
    
    % update figure
    drawnow limitrate;
    pause(0.01);
    hold off
    
    % plot excitation
    set(h1,'CurrentAxes',ax2);
    plot(tDFT,f(tDFT),'k','LineWidth',1.8);
    hold on
    grid on
    plot(ti,f(ti),'ro','LineWidth',2.0,'Markersize',9);
    hold off
    
    Frames(i) = getframe(gcf);
end

%% save frames
save('results/LShape_frame_data.mat', 'Frames');
% Frames1 = Frames(1:400);
% Frames2 = Frames(401:800);
% Frames3 = Frames(801:1001);
% save('results/LShape_frame_data1.mat', 'Frames1');
% save('results/LShape_frame_data2.mat', 'Frames2');
% save('results/LShape_frame_data3.mat', 'Frames3');





