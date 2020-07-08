% A very simple example of an analysis script. 
% Solves the problem of an elastic bar, which is fixed on one end and
% loaded by a volume load.

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name='nonlinearBar';
problem.dimension = 1;

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct( 'order', 1 ) );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_LINE_1D', struct('gaussOrder', 2, 'youngsModulus', 1, 'area', 1.0, 'massDensity', 1.0 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elementType1.nonlinearSystemMatricesCreator = @nonlinearSystemMatricesCreator;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0, 1.0 ];

% elements or 'quadrature supports'
problem.elementTopologies = [1];
problem.elementTypeIndices = [1];
problem.elementNodeIndices = { [ 1 2 ] };
                       
% elements or 'dof supports'
problem.subelementTopologies = [1];
problem.subelementTypeIndices = [1];
problem.subelementNodeIndices = { [ 1 2 ] };

% connections / transformations between elements and subelements
problem.elementConnections = { { { 1 1 } } };
                                   
% boundary conditions
u0 = 1;
problem.loads = { 1.5 };
problem.penalties = { [0, 1e60]; ...
                      [u0, 1e60] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { [] };
problem.elementPenalties = { [] };
problem.elementFoundations = { [] };

% nodal boundary condition connections
problem.nodeLoads = { [],[] };
problem.nodePenalties = { 1,2 };
problem.nodeFoundations = { [], [] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% % plot mesh and boundary conditions
% goPlotLoads(problem,1,0.1);
% goPlotMesh(problem,1);
% goPlotPenalties(problem,1);

%% linear analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

% add nodal forces
Fn = goCreateNodalLoadVector(problem);
F = F + Fn;

linearU = K \ F;

[ allUe ] = goDisassembleVector( linearU, allLe );

%% load displacement curve

% helper functions
clampLeftSide_Matrix = @(Matrix) Matrix(2:end,2:end);
clampLeftSide_Vector = @(Vector) Vector(2:end);
unclampLeftSide_Matrix = @(Matrix) blkdiag(0, Matrix);
unclampLeftSide_Vector = @(Vector) [0; Vector];


nSteps = 11;





nTotalDof = goNumberOfDof(problem);
U0 = zeros(nTotalDof,1);

U = U0;
% U = linearU;
[ allUe ] = goDisassembleVector( U, allLe );
% [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myStrainMeasures = { @linearStrain, ...
                     @greenLagrangeStrain, ...
                     @logarithmicStrain, ...
                     @almansiStrain };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nStrain = length(myStrainMeasures);
load = cell(nStrain,1);
displacement = cell(nStrain,1);


% for newton raphson solver
options = struct();
options.tol = 1e-10;
options.iter_max = 10;
options.stepSize = 1e-5;



uMin = -1.0*u0;
uMax = 1.0*u0;


for iStrain = 1:nStrain
    load{iStrain} = zeros(nSteps,1);
    displacement{iStrain} = zeros(nSteps,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    problem.strainMeasures = myStrainMeasures{iStrain};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for iStep = 1:nSteps
        
        loadScale = ((iStep-1)/(nSteps-1));
        problem.penalties{2}(1) = uMin + (uMax - uMin)*loadScale;
        Fn = goCreateNodalLoadVector(problem);
        
        % analysis
        fInt = @(U) internalLoad(problem, allLe, U);
        fExt = @() externalLoad(problem, allLe);
        R = @(U) fInt(U);
        F = fExt();
        
        U = newtonRaphsonSolver(R,F,U0,options);
        U = unclampLeftSide_Vector(U);              % why this works ?
        
        
        Fint = R(U);
        load{iStrain}(iStep) = Fint(end);
        displacement{iStrain}(iStep) = problem.penalties{2}(1);
        
    end
end

figure(1);
plot(displacement{1},load{1},'ko-','LineWidth',1.2);
hold on;
grid on;
for iStrain = 2:nStrain
    plot(displacement{iStrain},load{iStrain},'o-','LineWidth',1.2);
end
xlabel('u');
ylabel('F');
xlim([-1, 1]);
ylim([-1.5, 1.5]);
legend('linear', ...
       'Green Lagrange', ...
       'logarithmic', ...
       'Almansi', ...
       'Location', 'SouthEast');
title('displacement control');
