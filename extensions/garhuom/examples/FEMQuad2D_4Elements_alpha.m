
%% clear variables, close figures
clear all %#ok
clc
close all

format long;
%% problem definition
problem.name='FEM plate with a hole 2D 2 Elements conditioning';
problem.dimension = 2;

%% parameters
% polynomial degree
pA=8;

% material
E = 206900.0;
mu = 0.29;

R = 40;

load = 450;

i = 1;
k = 1;
%% Start analysis

    for p=1:2:pA
        % cell types
        elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', mu, 'thickness', 1 ));
        elementType1.mappingEvaluator = @myBlendedQuadMapping2;
        elementType1.jacobianEvaluator = @myBlendedQuadJacobian;

        elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', mu, 'thickness', 1 ));
        elementType2.mappingEvaluator = @myBlendedLineMapping;
        elementType2.jacobianEvaluator = @myBlendedLineJacobian;

    
        problem.elementTypes = { elementType1, elementType2 };

        problem.nodes=[ 0 100-R 100-(R*cos(pi/4)) 100 100 0;
                        0 0 R*sin(pi/4) R 100 100];

        problem.elementNodeIndices = { [ 1 2 3 6 ], [ 3 4 5 6 ],[1 2],[4 5],[5 6]};
        problem.elementTopologies = [ 2 2 1 1 1];
        problem.elementTypeIndices = [ 1 1 2 2 2];

        % subelement 
        subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct( 'order', p ) );
        subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct( 'order', p ) );
        problem.subelementTypes = { subelementType1, subelementType2 };

        problem.subelementNodeIndices = { [ 1 2 3 6 ]
            [ 3 4 5 6 ]
            [1 2]
            [2 3]
            [3 4]
            [4 5]
            [5 6]
            [1 6]
            [3 6]};
        problem.subelementTopologies = [ 2 2 1 1 1 1 1 1 1];
        problem.subelementTypeIndices = [ 1 1 2 2 2 2 2 2 2];

        problem = poCreateElementConnections( problem );

          % boundary conditions
        problem.loads = { [0 ; load] };
        penalty1 = [0, 0; 0, 1e20] ; %no movement in y
        penalty2 =  [ 0, 1e20; 0, 0] ; %no movement in x
        penalty3 =  [ 0, 1e20; 0, 1e20] ;
        problem.penalties = { penalty1, penalty2, penalty3};
        problem.foundations = { [] };

        problem.elementLoads = {[],[],[],[],1};
        problem.elementPenalties = {[],[], 1 ,2,[]};
        problem.elementFoundations = { [],[],[],[],[]};

        problem.nodeLoads = { [],[],[],[],[]};

        problem.nodePenalties = { 1,1,[],2,2,[]};
        problem.nodeFoundations = { [],[],[],[],[],[]};

        % quadrature types
%         problem.elementQuadratures = poSetupElementQuadratures(problem);

        % check and complete problem data structure
        problem = poCheckProblem(problem);

%         %% integration error
%         Aq = sum( [problem.elementQuadratures{1}.weights,problem.elementQuadratures{2}.weights,problem.elementQuadratures{3}.weights, problem.elementQuadratures{4}.weights] )*2500/4;
%         Aex = 100*100 - pi*(R)^2/4;
% 
%         relativeErrorIntegration = abs( (Aq - Aex) / Aex );

        %% analysis
        [ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

        [ K, F ] = goAssembleSystem(allKe, allFe, allLe);

        U = K \ F;

        [ allUe ] = goDisassembleVector( U, allLe );

        %% conditioning number
        %eigen = eig(K)

        %ke1 = allKe{1};
        ke2 = allKe{2};
        % cond
        %k = allKe{2}(2: end , 2: end);
        %cond(k)
        %condition(p) = cond(k);
        %anzatz = p;
        eigV = eig(ke2);
        %eigV_withNoZeros = eigV(eigV~=0)

        size_ = size(eigV,1);

        indices = find(abs(eigV)>1e19);
        eigV(indices) = [];


        size_ = size_-size(eigV,1);
        %eigV
        minEig = min(eigV);
        maxEig = max(eigV);
        condition(i) = abs(maxEig/minEig);
        i=i+1;
        %condition(p) = condest(K);

        %condition = abs(maxEig/minEig)
        %cond = cond(ke2)
    end
    i = 1;
    %% plot conditioning number
    figure(1)
    poly = 1:2:pA;
    semilogy(poly, condition, '-o', 'LineWidth',1.7,'MarkerSize',7)
    hold all;

    xlabel('polynomial degree $p$','FontSize',20, 'Interpreter','latex')
    ylabel('condition number $k$','FontSize',20, 'Interpreter','latex')

%     leg{k}=[append('q = ',num2str(q))];
%     k = k+1;
% 
%     %grid on;
%     annotation('textbox', [0.38, 0.8, 0.1, 0.1], 'String', "$\alpha = 10^{-q}$", 'Interpreter','latex', 'FontSize',16)
% leg = legend(leg) ;
% set(leg,'Location','northwest')

%% postprocess results
%plot integration points
% plotAdaptiveGaussLegendre2d( problem, 2)

%plot mesh and boundary conditions
goPlotMesh(problem,3);
goPlotLoads(problem,3, 0.03);
axis equal;

%plot displacement field
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 4);
axis equal;