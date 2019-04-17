% SiHoFemLab - Elastic Bar FCM
% We consider the elastic bar - as usual. This time, it is discretized by 
% two high-order elements that represent an extended domain [0,1].
% The bar, however, is only L=0.7 long, where 0.7 happens to be the root
% the level set function f(x)=x - 0.7. The geometry is not defined throu the
% mesh but only through this level set function. The domain [0,0.7], where
% f(x)<0 is called the physical domain. The domain [0.7,1] is called the
% ficticious domain.
%
%                        f(x)        /
%   /|---> ---> ---> ---> ---> ---> /
%   /|=============================/=========
%   /|          E,A,L             /
%                                /
%                     level set function

%% clear variables, close figures
clear all; %#ok
close all;

%% problem setup
problem.name = 'Elastic Bar FCM';
problem.dimension = 1;

% shape function order
pA = 6;

% physical properties
E=1.0;
A=1.0;

% geometry definition - in the physical domain, levelSetFunction < 0
levelSetFunction =@(x) x - 1;

% element types
elementType1 = poCreateElementTypeFCMLine1d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*pA,...
    'depth', 4,...
    'alphaFCM', 0.0,...
    'youngsModulus', E,...
    'area', A ) );

problem.elementTypes = { elementType1 };

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct( 'order', pA ) );
problem.subelementTypes = { subelementType1 };

% nodes
problem.nodes = [ 0.0, 0.5, 1.3];

% elements or 'quadrature supports'
problem.elementTopologies = [1 1];
problem.elementTypeIndices = [1 1];
problem.elementNodeIndices = { [ 1 2 ], [2 3] };

% subelements or 'dof supports'
problem.subelementTopologies = [1,1];
problem.subelementTypeIndices = [1,1];
problem.subelementNodeIndices = { [ 1 2 ], [ 2 3 ] };

% quadrature types - besides the new element type, this is the only thing
% that has to be done additionally in the FCM case, or any time, the
% element type uses the quadraturePointGetter 'predefinedQuadraturePoints'
problem.elementQuadratures = poSetupElementQuadratures(problem);

% connections / transformations between elements and subelements
problem = poCreateElementConnections( problem );

% boundary conditions
load =@(x) ( x.^4+x );
problem.loads = { load };
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


%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );

%% post processing
goPlotSolution1d( problem, allUe, 10, 2 );
goPlotQuadraturePoints1d( problem, 3 );

%% check
URef =[ 700.000000000000e-063 328.645833333333e-003 382.939699999754e-003 -13.2133933297456e-003 -3.58814987481898e-003 -115.998802913338e-006 -26.3060558476410e-006 -2.64385808971655e-006 -223.891760741179e-003 -56.1668699536250e-003 -9.06170027703484e-003 -993.020357458644e-006 -44.3565782607029e-006]';

relativeErrorU = norm( (U-URef)/norm(URef) ); %if pA=6

if relativeErrorU>1e-11
   error('exElasticBarFCM: Check failed if pA=6.');
else
   disp('exElasticBarFCM: Check passed.');
end

EKin=0.5*U'*K*U; 
ERef=0.14431818181818; %double checked with exElasticBar.m

relativeErrorE = norm( (EKin-ERef)/norm(ERef) );
if relativeErrorE>1e-12
   error('exElasticBarFCM: Check failed if pA>=6.');
else
   disp('exElasticBarFCM: Check passed.');
end
