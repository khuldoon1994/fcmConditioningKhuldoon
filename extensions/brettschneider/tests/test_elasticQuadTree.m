%%

clear
clc
close

%%

physicalDomainTestFunction =@(X)  -( (X(1,:) -100).^2 + (X(2,:) ).^2 - 10.^2);
quadratureType.depth = 7;

%%
problem.name='Test: Setup quadtree';
problem.dimension = 2;

pA = 2;

problem.nodes=[0 50 100 0 50 100 0 50 100 ; 0 0 0 50 50 50 100 100 100];

elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', { 'gaussOrder', pA+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 210000, 'poissonRatio', 0.3 } );
elementType1.physicalDomainTestFunction = physicalDomainTestFunction;
elementType1.quadratureType = quadratureType;

problem.elementTypes = { elementType1 };

problem.elementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ],[4 5 7 8], [5 6 8 9]};
problem.elementTopologies = [ 2 2 2 2 ];
problem.elementTypeIndices = [ 1 1 1 1 ];

subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', { 'order', pA+1 } );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', { 'order', pA+1 } );
problem.subelementTypes = { subelementType1, subelementType2 };
problem.subelementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ],[4 5 7 8], [5 6 8 9],[1 2],[1 4],[2,3],[2,5],[3,6],[4,5],[4,7],[5,6],[5,8],[6,9],[7,8],[8,9] };
problem.subelementTopologies = [ 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1];
problem.subelementTypeIndices = [ 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2];

problem = poCreateElementConnections( problem );

%loads
problem.loads = { [ 0.2; 0.0 ] };
problem.penalties = { [0,1e60; 0, 1e60] };
problem.foundations = { };

problem.elementLoads = {1 , 1, 1 ,1};
problem.elementPenalties = {[] [],[],[]};
problem.elementFoundations = { [],[],[],[]};

% nodal boundary condition connections
problem.nodeLoads = { [],[],[],[],[],[],1,[],1};
problem.nodePenalties = { 1,[],1,[],[],[],[],[],1};
problem.nodeFoundations = { [],[],[],[],[],[],[],[],[]};


%%
for i=1:length(problem.elementTypeIndices)
    problem.elementQuadratures{i}.spaceTree = eoSetupQuadTree(problem, i);
end
quadTree1 = problem.elementQuadratures{1}.spaceTree;
quadTree2 = problem.elementQuadratures{2}.spaceTree;

%%
plotQuadTree( problem, 2 )



%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );