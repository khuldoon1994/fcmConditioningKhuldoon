% An example of a one dimensional convergence study

%% clear variables and figures
%clear all; %#ok
%close all;

%% problem definition
L = 1;
%f = 0;
f = @(x) cos(2*pi*x)+ sin(2*pi*x);
E = 1;
A = 1;
rho = 1;

%% loop and increase number of dof
dofsP = zeros(1,10);
energyP = zeros(1,10);
omegaP = cell(1,10);
dofsH = zeros(1,10);
energyH = zeros(1,10);
omegaH = cell(1,10);
for i=1:10

    % h- convergence study
    p = 2;
    n = round(sqrt(2)^(1+i))-1;
%    problem = poCreateElasticBarProblem(1.0,1.0,1.0,p,n,f);
    problem = poCreateDynamicBarProblem(E, A, rho, L, p, n, f, 0,1,1);
    problem.elementTypes{1}.quadraturePointGetter=@blendedQuadrature1d;
    
    % analysis
%    [ allKe, allFe, allLe ] = goCreateElementMatrices( problem );
    [ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

    % add penalty constraints
    for elementIndex=1:n
        [ Kp, Fp ] = eoGetPenaltySystemMatrices(problem, elementIndex);
        allKe{elementIndex} = allKe{elementIndex} + Kp;
    end
    
    % assemble
%    [ K, F ] = goAssembleSystem(allKe, allFe, allLe);
    M = goAssembleMatrix(allMe, allLe);
    D = goAssembleMatrix(allDe, allLe);
    K = goAssembleMatrix(allKe, allLe);
    F = goAssembleVector(allFe, allLe);

    U = K \ F;

    % store dofs and energy
    dofsH(i) = numel(U);
    energyH(i) = 0.5 * U' * K * U;
    
    % eigenvalues  
    M(:,1)=[];
    M(1,:)=[];
    K(:,1)=[];
    K(1,:)=[];
    omegaH{i} = eigs(K,M,size(K,1));
    
    % p - convergence study
    n = 1;
    p = i;
    %problem = poCreateElasticBarProblem(1.0,1.0,1.0,p,n,f);
    problem = poCreateDynamicBarProblem(E, A, rho, L, p, n, f, 0,1,1);
    problem.elementTypes{1}.quadraturePointGetter=@blendedQuadrature1d;

    % analysis
    %[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );
    [ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

    % add penalty constraints
    for elementIndex=1:n
        [ Kp, Fp ] = eoGetPenaltySystemMatrices(problem, elementIndex);
        allKe{elementIndex} = allKe{elementIndex} + Kp;
    end
    
    % assemble
%    [ K, F ] = goAssembleSystem(allKe, allFe, allLe);   
    M = goAssembleMatrix(allMe, allLe);
    D = goAssembleMatrix(allDe, allLe);
    K = goAssembleMatrix(allKe, allLe);
    F = goAssembleVector(allFe, allLe);

    % solve static
    U = K \ F;

    % store dofs and energy
    dofsP(i) = numel(U);
    energyP(i) = 0.5 * U' * K * U;

    % eigenvalues
    M(:,1)=[];
    M(1,:)=[];
    K(:,1)=[];
    K(1,:)=[];
    omegaP{i} = eigs(K,M,size(K,1));

end

%% plot last solution
figure(1);
[ allUe ] = goDisassembleVector( U, allLe );
goPlotSolution1d( problem, allUe, 2*p, 1 );


%% reference solution
% reference = 0.375;                    % for constant load f=1.5
reference = 2.53302959105658997e-02;    % for load f = @(x) cos(2*pi*x) + sin(2*pi*x)
errorH = abs(energyH-reference)/reference;
errorP = abs(energyP-reference)/reference;

n = 100;
n = linspace(1,n,n);
c = sqrt(E/rho);
omega = (2*n-1)*pi*c/2/L;
omegaSorted = sort(omega);

errorOmegaH = zeros(1,10);
errorOmegaP = zeros(1,10);
iOmega=1;
for i=1:10
    %iOmega=round(numel(omegaP{i})/4)+1;
    errorOmegaP(i) = abs(omega(iOmega)-sqrt(omegaP{i}(iOmega)))/omega(iOmega);
    %iOmega=round(numel(omegaH{i})/4)+1;
    errorOmegaH(i) = abs(omega(iOmega)-sqrt(omegaH{i}(iOmega)))/omega(iOmega);    
end

%% plot convergence
figure(2);
loglog(dofsH,errorH,'b-+');
hold on;
loglog(dofsP,errorP,'r-+');
loglog(dofsH,errorOmegaH,'b-x');
loglog(dofsP,errorOmegaP,'r-x');
legend('h-convergence','p-convergence');
xlabel('number of degrees of freedom');
ylabel('relative error');
grid on;
  

%% eigenvalues
figure(3);
semilogy(sqrt(omegaH{end}));
hold on;
semilogy(sqrt(omegaP{end}));
semilogy(omegaSorted);
legend('finest h','finest p');
xlabel('number');
ylabel('eigenvalue');
grid on;


%% check
referenceEnergyH=[ 1.85499928445920295e-02  2.41480346685204843e-02  2.50423611623456013e-02  2.52888925214569543e-02  2.53192084128315877e-02  2.53275935361976789e-02  2.53297578203139813e-02  2.53301792253727738e-02  2.53302662690642888e-02  2.53302886014850070e-02 ];
referenceEnergyP=[ 1.27815321666995274e-02  1.85499928445920295e-02  2.29369058834101441e-02  2.48436815331790142e-02  2.52747635393382707e-02  2.53260238955871492e-02  2.53300617167968763e-02  2.53302862545295264e-02  2.53302956001568505e-02  2.53302959025777132e-02 ];
if norm(abs(referenceEnergyH-energyH))>1e-15 || norm(abs(referenceEnergyP-energyP))>1e-15
   error('exElasticBarConvergenceStudy: Check failed.');
else
   disp('exElasticBarConvergenceStudy: Check passed.');
end
