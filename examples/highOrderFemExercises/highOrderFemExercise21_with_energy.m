% The elastic bar problem considered in exercise 2.1

%% clear variables, close figures
clear all; %#ok
close all;

%% variables
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x) 0.1*(1-x/L);

p = 1;

%% reference solution
refDisp = @(x) x.^3/60 - x.^2/20 + x/20;
refStrain = @(x) x.^2/20 - x./10 + 1/20;
energyDensity = @(x) refStrain(x).*refStrain(x)*E*A;
refEnergy = integral(energyDensity, 0, L);

%% problem definition
problem.name='high order fem exercise 2.1';
problem.dimension = 1;

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct('order', p) );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_LINE_1D', struct('gaussOrder', p+1, 'youngsModulus', E, 'area', A) );
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0, 0.5*L, L ];

% elements or 'quadrature supports'
problem.elementTopologies = [1 1];
problem.elementTypeIndices = [1 1];
problem.elementNodeIndices = { [ 1 2 ], [2 3] };

% subelements or 'dof supports'
problem.subelementTopologies = [1,1];
problem.subelementTypeIndices = [1,1];
problem.subelementNodeIndices = { [ 1 2 ], [ 2 3 ] };

% connections / transformations between elements and subelements
problem.elementConnections = { { { 1 1 } }, { { 2 1 } } };
                                   
% boundary conditions
problem.loads = { f };
problem.penalties = { [0, 1e60] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

% nodal boundary condition connections
problem.nodeLoads = { [], [], [] };
problem.nodePenalties = { 1, [], [] };
problem.nodeFoundations = { [], [], [] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = moSolveSparseSystem(K,F);

[ allUe ] = goDisassembleVector( U, allLe );

%% post processing
goPlotSolution1d( problem, allUe, 10, 2 );
subplot(2,2,1);
x=linspace(0,L,20);
y=refDisp(x);
plot(x,y,'k-');

% easy energy computation
femEnergy1 = sqrt(0.5*U'*K*U)

% energy computation thru integral
N = @(problem, elementIndex, xi) eoEvaluateShapeFunctionGlobalDerivative( problem, elementIndex, xi );
integrand = @(problem, elementIndex, xi, jacobian, detJ, Ue) E*A* (N(problem, elementIndex, xi) * Ue)*(N(problem, elementIndex, xi) * Ue);
elementEnergy1 = eoIntegrateSolutionFunction( problem, 1, allUe{1}, integrand );
elementEnergy2 = eoIntegrateSolutionFunction( problem, 2, allUe{2}, integrand );

femEnergy2 = sqrt(0.5*(elementEnergy1 + elementEnergy2))

% complicated energy computation
syms x;
hatFun = @(x) max(0,1-2*abs(x));

N1 = @(x) hatFun(x);
N2 = @(x) hatFun(x-0.5);
N3 = @(x) hatFun(x-1);

dN1 = @(x) dHatFun(x);
dN2 = @(x) dHatFun(x-0.5);
dN3 = @(x) dHatFun(x-1);

figure(3)
hold on;
fplot(N1,[0,L]);
fplot(N2,[0,L]);
fplot(N3,[0,L]);

femDisp = @(x) N1(x)*U(1) + N2(x)*U(2) + N3(x) * U(3);
femStrain = @(x) dN1(x)*U(1) + dN2(x)*U(2) + dN3(x) * U(3);
femEnergyDensity = @(x) E*A*femStrain(x).*femStrain(x);

figure(4)
hold on;
fplot(femDisp,[0,L]);
fplot(femStrain,[0,L]);
fplot(femEnergyDensity,[0,L]);

femEnergy3 = sqrt(0.5* integral(femEnergyDensity,0,L) )

%% check
URef=[ 5.00000000000000020e-62  1.45833333333333353e-02  1.66666666666666699e-02 ]';
if sum(URef==U)~=numel(U)
   disp('ERROR! Check failed!'); 
end


%% function definitions
function out=dHatFun(x) 
    out = zeros(size(x));
    for i=1:numel(x)
    if x(i)>=0.0
        if x(i)<=0.5
          out(i) = -2;
        end
    else
        if x(i)>=-0.5
          out(i) = 2;
        end
    end
    end
end
 
