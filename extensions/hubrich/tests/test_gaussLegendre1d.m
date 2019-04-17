
clear
close all
clc

%%

problem.name = 'Test: Gauss-Legendre 1d';

problem.dimension = 1;
pA = 5;

% element types
E=1.0; A=1.0;
elementType1 = poCreateElementTypeLine1d( {'gaussLegendre', 2*pA, 'youngsModulus', E, 'area', A} );

problem.elementTypes = { elementType1 };

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', { 'order', pA } );
problem.subelementTypes = { subelementType1 };

% nodes
problem.nodes = [ 0.0, 0.5, 1 ];

% elements or 'quadrature supports'
problem.elementTopologies = [1 1];
problem.elementTypeIndices = [1 1];
problem.elementNodeIndices = { [ 1 2 ], [2 3] };

% subelements or 'dof supports'
problem.subelementTopologies = [1,1];
problem.subelementTypeIndices = [1,1];
problem.subelementNodeIndices = { [ 1 2 ], [ 2 3 ] };

% quadrature types
problem = poSetupElementQuadratures(problem);

% connections / transformations between elements and subelements
problem = poCreateElementConnections( problem );

% boundary conditions
f =@(x) ( -sin(8*x) );
problem.loads = { f };
problem.penalties = { [0, 1e60] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [],[] };
problem.elementFoundations = { [],[] };

% nodal boundary condition connections
problem.nodeLoads = { [],[],[] };
problem.nodePenalties = { 1,[],[] };
problem.nodeFoundations = { [],[],[] };

%
%poCheckProblem(problem);
goPlotMesh(problem,1);

%
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

%
[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

%
U = K \ F;

%
[ allUe ] = goDisassembleVector( U, allLe );

%
plotSolutionOverMesh1d( problem, allUe, 10, 2 );

%% check results with results from example step1.m and step2.m

Uref = [-1.431875033004876e-61 ; 2.731287911261502e-03 ; -3.364622798834351e-02 ; 3.030523926804557e-02 ; -8.161017037680605e-03 ; ...
        -6.455763826049659e-03 ; 7.776318977855208e-04 ; -9.312413384561260e-03 ; 1.882981049055896e-02 ; 1.983773859349187e-03 ; ...
        -1.794220156520658e-03];

relativeErrorU = norm( (U-Uref)/norm(Uref) )
