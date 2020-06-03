%% Solves the following problem:

%            3 - 4
% penalty    |   |   traction
%            1 - 2

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();


%% problem definition
problem.name='elasticQuad';
problem.dimension = 2;

% polynomial degree
p=2;

% element types
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3, 'thickness', 1) );
elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3, 'thickness', 1) );
problem.elementTypes = { elementType1, elementType2 };

% mesh data
problem.nodes = [ 0.0, 1.0, 0.0, 1.0;
                  0.0, 0.0, 1.0, 1.0 ];

problem.elementTopologies = [ 2 1 1 ];
problem.elementTypeIndices = [ 1 2 2 ];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 3 ]        % needed for penalty boundary condition 
    [ 2 4 ]        % needed for the traction boundary condition
};

% the mesh would normally be created automatically, e.g
% [ problem.nodes, problem.cells ] = readMesh(adhocMeshFile.qua);    

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', p) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', p) );
problem.subelementTypes = { subelementType1, subelementType2 };

% subelements
problem = poCreateSubElements( problem );    

% element cell connection
problem = poCreateElementConnections( problem );


% boundary conditions
problem.loads = { [ 0.15; 0.0 ] };
problem.penalties = { [0, 1e15; 0, 1e15] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { [] [] 1 };
problem.elementPenalties = { [] 1 [] }; % penalty has to be enforced on edge modes
problem.elementFoundations = { [],[] ,[] };

% nodal boundary condition connections
problem.nodeLoads = { [],[],[],[] };
problem.nodePenalties = { 1,[],1,[] };
problem.nodeFoundations = { [],[],[] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);
goPlotLoads(problem,1,1);
goPlotPenalties(problem,1);
title('Problem setup');
axis equal;


%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );


%% post processing
postGridCells = goCreatePostGrid( problem, 5 );
figure(2);
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
axis equal;
title('Displacement solution');

%% check
URef = [ 2.49999999999999995e-17  4.05379813635572004e-18  1.29564739090262893e-01  2.75437531149397181e-02  2.49999999999999902e-17 -4.05379813635572236e-18  1.29564739090262809e-01 -2.75437531149396453e-02 -1.79582654660750199e-02 -1.05630711909291180e-17 -5.61616373706569342e-17  1.70409613311061014e-33 -5.37005822537550866e-03  9.73828950985845265e-19 -2.51227826673584972e-03 -2.43594136673668735e-02 -2.51227826673585146e-03  2.43594136673668596e-02 ]';
if norm(abs(URef-U))>1e-16
   error('exElasticQuad: Check failed!');
else
    disp('exElasticQuad: Check passed.');
end
