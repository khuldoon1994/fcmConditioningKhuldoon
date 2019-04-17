
%%

clear
clc
close

%%

physicalDomainTestFunction =@(X) -( (X(1,:) - 1).^2 + (X(2,:) - 1).^2 - 0.75^2 );
quadratureType.depth = 5;
quadratureType.order = 2;
%quadratureType.alphaFCM = 0.0;

%%
problem.name='Test: Setup adaptive integration 2d';
problem.dimension = 2;

pA = 2;

problem.nodes=[0 2 0 2 ; 0 0 2 2];

elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', { 'gaussOrder', pA+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3 } );
elementType1.physicalDomainTestFunction = physicalDomainTestFunction;
elementType1.quadratureType = quadratureType;

problem.elementTypes = { elementType1 };

problem.elementNodeIndices = { [ 1 2 3 4 ] };
problem.elementTopologies = [ 2 ];
problem.elementTypeIndices = [ 1 ];

%%

problem = eoSetupAdaptiveGaussLegendre2d( problem, 1 );

ng = length(problem.elementQuadratures{1}.weights)

%%

Aq = sum( problem.elementQuadratures{1}.weights )
Aex = 4 - pi*0.75^2

e_r = abs( (Aq - Aex) / Aex )

%% plot adaptive gauss legendre 2d

plotAdaptiveGaussLegendre2d( problem, 1 )


