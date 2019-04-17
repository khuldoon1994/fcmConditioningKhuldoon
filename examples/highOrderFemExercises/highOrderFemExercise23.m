% The elastic bar problem considered in exercise 2.3

%% clear variables, close figures
clear all; %#ok
close all;

%% variables
E = 1.0;
A = 1.0;
L = 1.0;

lambda=10;
refEnergy = 6.52928625099011217e+00;

%lambda=0.65;
%refEnergy = 4.77917633472061232e-01;

f = @(x) lambda*(lambda-1)*x^(lambda-2);
ref = @(x) -x.^lambda + lambda*x;



error=zeros(1,8);
dof=zeros(1,8);
for i=1:8

    p = i;
    n = 1;

    %% problem definition
    problem = poCreateElasticBarProblem(E,A,L,p,n,f);
    problem.elementTypes{1}.quadraturePointGetterData.gaussOrder = 11;

    % check and complete problem data structure
    problem = poCheckProblem(problem);

    % plot mesh and boundary conditions
    goPlotMesh(problem,1);

    %% analysis
    [ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

    [ K, F ] = goAssembleSystem(allKe, allFe, allLe);

    U = moSolveSparseSystem(K,F);

    [ allUe ] = goDisassembleVector( U, allLe );

    dof(i) = size(U,1);
    error(i) = sqrt(abs(refEnergy^2-0.5*U'*K*U))/refEnergy;

end

%% post processing
figure(2);
goPlotSolution1d( problem, allUe, 10, 2 );
subplot(2,2,1);
x=linspace(0,L,20);
y=ref(x);
plot(x,y,'k-');

figure(3)
loglog(dof,error);


%% check
URef=[ 9.99999999999999841e-15  9.00000000000000711e+00 -1.00206398568402721e+00 -8.62439361864102971e-01 -5.49474161694075369e-01 -2.67019343944568555e-01 -9.84003306256662630e-02 -2.67431093370274695e-02 -5.06941898143404082e-03 ]';
if sum(URef==U)~=numel(U)
   disp('ERROR! Check failed!'); 
end
