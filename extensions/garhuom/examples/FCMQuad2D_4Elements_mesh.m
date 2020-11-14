
%% clear variables, close figures
clear all %#ok
clc
close all

format long;
%% problem definition
problem.name='FCM plate with a hole 2D 4 Elements conditioning for different alpha with varying element size';
problem.dimension = 2;

%% parameters
% polynomial degree
pA=12;

% integration depth
n=7;

% material
E = 50.0;
mu = 0.3;

R = 60;

load = -0.1;

% Mesh Size
element_num = 10;
node_num = element_num + 1;

i = 1;
k = 1;
%% Start analysis
for q=[18,12,9,7,5,4,3,2]

    alpha = 10.0^(-q);
    
    %level set
    %R=10;
    X0 = 100;
    Y0 = 0;
    levelSetFunction =  @(X) -( (X(1,:) -X0).^2 + (X(2,:) -Y0 ).^2 - R.^2);
    
    condition_alpha = zeros(1,6);
    fcmEnergy_alpha = zeros(1,6);

    for p=2:2:pA
        % cell types
        elementType1 = poCreateFCMElementTypeQuad2d( struct( ...
            'levelSetFunction', levelSetFunction, ...
            'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
            'gaussOrder', 2*p,...
            'depth', n,...
            'alphaFCM', alpha,...
        'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', mu));

        elementType2 = poCreateFCMElementTypeLine2d( struct( ...
            'levelSetFunction', levelSetFunction, ...
            'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
            'gaussOrder', 2*p,...
            'depth', n,...
            'alphaFCM', alpha,...
        'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', mu));

        problem.elementTypes = { elementType1, elementType2 };
        
        problem.nodes = zeros(2,(node_num*node_num));
        problem.nodes(:,1) = [0,0]; 
        for a = 2 : 1 : (node_num*node_num)
            if problem.nodes(1,a-1) == 100
                problem.nodes(1,a) = 0;
                problem.nodes(2,a:a+(node_num-1)) = problem.nodes(2,a-1) + (100/element_num);
            else
            problem.nodes(1,a) = problem.nodes(1,a-1) + (100/element_num);
            end
        end
        
        %numbering for penalty constraints
        %number of quads
        elementNodeIndices1=cell(1,(element_num*element_num));
        a = 1;
        while a+(node_num+1) <= (node_num*node_num)
            if mod(a,node_num) == 0
                a = a + 1;
            else
                elementNodeIndices1(a) = { [ a a+1 a+(node_num) a+(node_num+1) ]};
                a = a + 1;
            end
        end
        emptyCells = cellfun(@isempty,elementNodeIndices1);
        elementNodeIndices1(emptyCells) = [];
        %number of lines
        elementNodeIndices2 = cell(1, 3*element_num);
        a = 1;
        while a+1 <= (node_num)
        elementNodeIndices2(a) = {[a a + 1]};
        elementNodeIndices2(a+(node_num-1)) = {[(a*node_num) ((a+1)*node_num)]};
        elementNodeIndices2(a+(2*(node_num-1))) = {[a+(node_num*element_num) (a+(node_num*element_num))+1]};
        a = a + 1;
        end
        problem.elementNodeIndices = [ elementNodeIndices1, elementNodeIndices2 ];
        for a = 1:1:numel(problem.elementNodeIndices)
            if numel(problem.elementNodeIndices{a}) == 4
                problem.elementTopologies(a) = 2;
                problem.elementTypeIndices(a) = 1;
            elseif numel(problem.elementNodeIndices{a}) == 2
                problem.elementTopologies(a) = 1;
                problem.elementTypeIndices(a) = 2;
            else
                error("Not a 2D or 1D element")
            end
        end

        % subelement 
        subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct( 'order', p ) );
        subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct( 'order', p ) );
        problem.subelementTypes = { subelementType1, subelementType2 };

        %subelement node numbering
        %quads
        subelementNodeIndices1=cell(1,(element_num*element_num));
        a = 1;
        while a+(node_num+1) <= (node_num*node_num)
            if mod(a,node_num) == 0
                a = a + 1;
            else
                subelementNodeIndices1(a) = { [ a a+1 a+(node_num) a+(node_num+1) ]};
                a = a + 1;
            end
        end
        subemptyCells = cellfun(@isempty,subelementNodeIndices1);
        subelementNodeIndices1(emptyCells) = [];
        subelementNodeIndices2 = cell(1, 2*(element_num)*(node_num));
        a = 1;
        b = 1;
        while a <= (2*(element_num)*(node_num))
            if b <= (element_num*node_num)
                if mod(b,node_num) ~= 0
                    subelementNodeIndices2(a) = {[b b+1]};
                    subelementNodeIndices2(a+1) = {[b b+(node_num)]};
                    b = b + 1;
                    a = a + 2;
                else
                    subelementNodeIndices2(a) = {[b b+(node_num)]};
                    b = b + 1;
                    a = a + 1;
                end
            else
                    subelementNodeIndices2(a) = {[b b+1]};
                    b = b + 1;
                    a = a + 1;
            end
        end
        problem.subelementNodeIndices = [ subelementNodeIndices1, subelementNodeIndices2 ];
       for a = 1:1:numel(problem.subelementNodeIndices)
            if numel(problem.subelementNodeIndices{a}) == 4
                problem.subelementTopologies(a) = 2;
                problem.subelementTypeIndices(a) = 1;
            elseif numel(problem.subelementNodeIndices{a}) == 2
                problem.subelementTopologies(a) = 1;
                problem.subelementTypeIndices(a) = 2;
            else
                error("Not a 2D or 1D element")
            end
        end

        problem = poCreateElementConnections( problem );

          % boundary conditions
        problem.loads = { [0 ; load] };
        penalty1 = [0, 0; 0, 1e20] ; %no movement in y
        penalty2 =  [ 0, 1e20; 0, 0] ; %no movement in x
        penalty3 =  [ 0, 1e20; 0, 1e20] ;
        problem.penalties = { penalty1, penalty2, penalty3};
        problem.foundations = { [] };

        problem.elementLoads = {[],[],[],[],[],[],[],[],1,1};
        problem.elementPenalties = {[],[],[],[],1 ,1, 2 ,2,[],[],};
        problem.elementFoundations = { [],[],[],[],[],[],[],[],[],[] };

        problem.nodeLoads = { [],[],[],[],[],[],[],[],[]};

        problem.nodePenalties = { 1,1,3,[],[],2,[],[],2};
        problem.nodeFoundations = { [],[],[],[],[],[],[],[],[],[] };
        

        % quadrature types
        problem.elementQuadratures = poSetupElementQuadratures(problem);

        % check and complete problem data structure
        problem = poCheckProblem(problem);

        %% integration error
        Aq = sum( [problem.elementQuadratures{1}.weights,problem.elementQuadratures{2}.weights,problem.elementQuadratures{3}.weights, problem.elementQuadratures{4}.weights] )*2500/4;
        Aex = 100*100 - pi*(R)^2/4;

        relativeErrorIntegration = abs( (Aq - Aex) / Aex );

        %% analysis
        [ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

        [ K, F ] = goAssembleSystem(allKe, allFe, allLe);

        U = K \ F;

        [ allUe ] = goDisassembleVector( U, allLe );

        %% conditioning number
        %eigen = eig(K)

        %ke1 = allKe{1};
        %ke2 = allKe{2};
        % cond
        %k = allKe{2}(2: end , 2: end);
        %cond(k)
        %condition(p) = cond(k);
        %anzatz = p;
        [V, D] = qdwheig(full(K));
        eigV = diag(D);
        %eigV_withNoZeros = eigV(eigV~=0)

        size_ = size(eigV,1);

        indices = find(abs(eigV)>1e19);
        eigV(indices) = [];
        
        min_value = find(abs(eigV)==0);
        eigV(min_value) = 1e-18;
        
        size_ = size_- size(eigV,1);
        %eigV
        minEig = min(eigV);
        maxEig = max(eigV);
        condition_alpha(i) = abs(maxEig/minEig);
        fcmEnergy_alpha(i) = 0.5*U'*K*U;
        U_alpha = U;
        i=i+1;
        %condition(p) = condest(K);

        %condition = abs(maxEig/minEig)
        %cond = cond(ke2)
    end
    i = 1;
    %% plot conditioning number
    figure(1)
    poly = 2:2:pA;
    semilogy(poly, condition_alpha, '-o', 'LineWidth',1.7,'MarkerSize',7)
    hold on;
    
    xlabel('polynomial degree $p$','FontSize',20, 'Interpreter','latex')
    ylabel('condition number $k$','FontSize',20, 'Interpreter','latex')
    leg{k}= [append('q = ',num2str(q))];
    
    
%     %grid on;
%     annotation('textbox', [0.38, 0.8, 0.1, 0.1], 'String', "$\alpha = 10^{-q}$", 'Interpreter','latex', 'FontSize',16)
%     
%     figure(2)
%     plot(poly, fcmEnergy_alpha, '-o', 'LineWidth',1.7,'MarkerSize',7)
%     hold on;
%     xlabel('polynomial degree $p$','FontSize',20, 'Interpreter','latex')
%     ylabel('Strain Energy $k$','FontSize',20, 'Interpreter','latex')

%     leg{k}= [append('q = ',num2str(q))];
    %grid on;
    annotation('textbox', [0.38, 0.8, 0.1, 0.1], 'String', "$\alpha = 10^{-q}$", 'Interpreter','latex', 'FontSize',16)
    
    k = k+1;
end
leg = legend(leg) ;
set(leg,'Location','northwest')

%% postprocess results
%plot integration points
plotAdaptiveGaussLegendre2d( problem, 2)

%plot mesh and boundary conditions
goPlotMesh(problem,3);
goPlotLoads(problem,3, 0.03);
axis equal;

%plot displacement field
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 4);
axis equal;