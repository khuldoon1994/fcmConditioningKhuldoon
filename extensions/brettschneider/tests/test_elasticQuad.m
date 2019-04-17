%% Solves the following problem:

%            3 - 4
% penalty    |   |   traction
%            1 - 2

%% clear variables, close figures
clear all;
close all;


%% problem definition
problem.name='elasticQuadTest';
problem.dimension = 2;

% polynomial degree
p=2;

% cell types
elementType1 = poCreateElementTypeQuad2d( {'gaussLegendre', 2*p, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3  });
elementType2 = poCreateElementTypeLine2d( {'gaussLegendre', 2*p, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3  });
problem.elementTypes = { elementType1, elementType2 };

% mesh data
problem.nodes = [ 0.0, 1.0, 0.0, 1.0;
                  0.0, 0.0, 1.0, 1.0 ];

% low order
%problem.elementTopologies = [ 2 1 ];
%problem.elementTypeIndices = [ 1 2 ];
%problem.elementNodeIndices = {
%    [ 1 2 3 4 ]      % a quad (2) of cell type (1) with nodes (1 2 3 4) - the 'main element'
%    [ 2 4 ]          % a line (1) of cell type (2) with nodes (2 4) - for traction integration
%};

% high order
problem.elementTopologies = [ 2 1 1 ];
problem.elementTypeIndices = [ 1 2 2 ];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 3 ]        % needed for penalty constraint 
    [ 2 4 ]        
};

% this could be done automatically, e.g 
% [ problem.nodes, problem.cells ] = readMesh(adhocMeshFile.qua);    

% subelement types
% low order
%subelementType1 = createElementType( 'LINEAR_QUAD', { } );
%problem.subelementTypes = { elementType1 };


% high order
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', { 'order', p } );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', { 'order', p } );
problem.subelementTypes = { subelementType1, subelementType2 };

% subelements
% low order
%problem.subelementTopologies = [ 2 ];
%problem.subelementTypeIndices = [ 1 ];
%problem.subelementNodeIndices = {
%    [ 1 2 3 4 ]
%};


% high order
problem.subelementTopologies = [ 2, 1, 1, 1, 1 ];
problem.subelementTypeIndices = [ 1, 2, 2, 2, 2 ];
problem.subelementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 2 ]
    [ 3 4 ]
    [ 1 3 ]
    [ 2 4 ]
};

% this could be done automatically, e.g 
% problem.subelements = { problem.elements, createEdgesFromFaces(problem.elements) };    

% element cell connection
%problem.cellElementConnections = {
%    { { 1 [ 1, 0; 0, 1] } },
%    { { 1 [ 0, 1; 1, 0] } }
%};

% high order
problem.elementConnections = {
    { { 1 [ 1, 0; 0, 1] }
      { 2 [ 1, 0; 0,-1] }
      { 3 [ 1, 0; 0, 1] }
      { 4 [ 0, 1;-1, 0] }
      { 5 [ 0, 1; 1, 0] } }
    { { 4 [ 1, 0; 0,-1] } } % No connection to subelement 1 because the penaltymatrix is wrong in that case
    { { 1 [ 0, 1; 1, 0] }
      { 5 [ 1, 0; 0, 1] } }      
};

% this can be done automatically, e.g 
%problem.cellElementConnections = createElementConnections( cells, elements ); 


% boundary conditions
problem.loads = { [ 0.15; 0.0 ] };
problem.penalties = { [0, 1e60; 0, 1e60] };
problem.foundations = { };

% element boundary condition connections

% low order
%problem.elementLoads = {
%    [] 1
%};
%problem.elementPenalties = {
%    [] []
%};

% high order
% element boundary condition connections
problem.elementLoads = {[], [],1};
% penalty has to be enforced on edge modes
problem.elementPenalties = { [],1, []};
problem.elementFoundations = { [],[] };


% nodal boundary condition connections
problem.nodeLoads = { [],[],[],[]};
problem.nodePenalties = { 1,[],1,[]};
problem.nodeFoundations = { [],[] };

% quadrature types

problem = poSetupElementQuadratures(problem);

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);
plotLoads(problem,1);
view(3);
axis equal;


%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );


%% post processing
% postGridCells = goCreatePostGrid( problem, 5 );
% plotPostGrid( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
% view(3)
% axis equal;

% writeVtuFile( problem, Ue, ['DISPLACEMENT','STRAIN', 'STRESS']);

Uref=[3.75000000000000e-62;6.08069720453358e-63;0.129564739090263;0.0275437531149397;3.75000000000000e-62;-6.08069720453359e-63;0.129564739090263;-0.0275437531149397;-0.0179582654660750;-1.95839136249950e-17;-0.00251227826673583;-0.0243594136673669;-0.00251227826673583;0.0243594136673668;-5.61616373706570e-62;-6.92220881102938e-78;-0.00537005822537547;-1.62204931143554e-17];
% Uref=[3.75000000000000e-17;4.92068771424227e-18;0.133696908620890;0.0315697294200060;3.75000000000000e-17;-4.92068771424226e-18;0.133696908620890;-0.0315697294200057;-0.0124381543803411;5.47599212870284e-17;-6.11171562139553e-17;-0.00128693384928359;0.0155910181562596;9.44235227005145e-17;-5.89043495034948e-17;-0.0153706593484219;-0.00129571714215586;-0.0220143223620727;0.00392897496927404;0.0157370898190165;-0.00129571714215588;0.0220143223620729;0.00392897496927399;-0.0157370898190165;-5.65264755059309e-17;-3.19607732733201e-33;1.16624081500797e-32;2.57443331642861e-18;0.00253533220389593;7.38761555175060e-17;-1.01293056588609e-16;-0.00324376467724697]%
%Uref depending on Penalty 1e60 or 1e15;

relativeErrorU = norm( (U-Uref)/norm(Uref) )