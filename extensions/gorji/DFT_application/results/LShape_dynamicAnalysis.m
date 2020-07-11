
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

% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = T;
problem.dynamics.nTimeSteps = N + 1;

allDisplacements = uDFT;
allDisplacements(:,end+1) = uDFT(:,1);
allUeDynamic = goDisassembleDynamicVector(problem, allDisplacements, allLe);

figure();
iFig = get(gcf,'Number');
postGridCells = goCreatePostGrid( problem, 0 );
goPlotAnimatedPostGridSolution( problem, allUeDynamic, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, iFig);


