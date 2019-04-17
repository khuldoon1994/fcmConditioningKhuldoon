
clear
close all
clc

%%

problem.name = 'Test: FVM Line 2d';

problem.dimension = 2;
p = 2;
% physicalDomainTestFunction =@(X)-1;
R=0.1; %Kreisradius
physicalDomainTestFunction =@(X) -( (X(1,:) -1/sqrt(2)).^2 + (X(2,:) -1/sqrt(2)).^2 -R^2 );

% element types
E=1.0; A=1.0;
elementType1 = poCreateFCMElementTypeLine2d( {'physicalDomain',physicalDomainTestFunction,'adaptiveGaussLegendre', 2*p, 'depth' , 4 ,'alphaFCM',0.0, 'physics', 'PLANE_STRAIN', 'youngsModulus', 206900, 'poissonRatio', 0.29 });
problem.elementTypes = { elementType1 };

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_EDGE', { 'order', p } );
problem.subelementTypes = { subelementType1 };

% nodes
problem.nodes = [ 0.0, 0.5/sqrt(2), 1/sqrt(2) 
                    0,0.5/sqrt(2), 1/sqrt(2)];

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
f =@(X) ( 1/sqrt(2)*(-sin(8*X(1,:))+sin(8*X(2,:))) );
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
plotAdaptiveGaussLegendreLine2d( problem, 2 )

% % This Part of the code doesn't work because the Stiffness Matrices are
% %assenbled wrong

%[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

% %
% [ K, F ] = goAssembleSystem(allKe, allFe, allLe);
% 
% %
% U = K \ F;
% 
% %
% [ allUe ] = goDisassembleVector( U, allLe );

%
%plotSolutionOverMesh1d( problem, allUe, 10, 2 );

