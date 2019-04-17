function [ solutionQuantities ] = goSolveLinearDynamics(problem, solutionPointer, U0Dynamic, V0Dynamic)
%calculate the displacement, its velocity and acceleration
%with a time integration method (specified by the user before)

% there are two input, which represent the initial values
% UDynamic is the initial displacement
% VDynamic is the initial velocity
% there is an additional input called solutionPointer
% solutionPointer 'says' to our function in which outputs we are interested

% solutionPointer has the structure {Pointer1, Pointer2, ...}
% solutionQuantities has the structure {Solution1, Solution2, ...}
% every Pointer (e.g. Pointer1) refers to one solution (e.g. Solution1)

% e.g. type the following code
% Pointer1 = {'displacement', [1]}
% Pointer2 = {'velocity', [2, 3]}
% Pointer3 = {'acceleration', 'nodes'}
% solutionPointer = {Pointer1, Pointer2, Pointer3}
%
% [ solutionQuantities ] = goSolveLinearDynamics(problem, solutionPointer)
%
% displacementAtFirstNode = solutionQuantities{1};
% velocityAtSecondAndThirdNode = solutionQuantities{2};
% accelerationAtAllNodes = solutionQuantities{3};


    
    timeIntegration = problem.dynamics.timeIntegration;
    [ nTotalDof ] = goNumberOfDof(problem);
    
    % set initial values to zero if not defined
    if nargin < 2
        solutionPointer = {{'displacement', 'all'}, ...
                            {'velocity', 'all'}, ...
                            {'acceleration', 'all'}};
    end
    if nargin < 3
        U0Dynamic = zeros(nTotalDof,1);
    end
    if nargin < 4
        V0Dynamic = zeros(nTotalDof,1);
    end
    
    % create system matrices
    [ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );
    
    % assemble
    M = goAssembleMatrix(allMe, allLe);
    D = goAssembleMatrix(allDe, allLe);
    K = goAssembleMatrix(allKe, allLe);
    F = goAssembleVector(allFe, allLe);
    
    % compute initial acceleration
    [ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);
    
    % put necessary variables into cells
    globalMatrices = {M, D, K, F};
    globalInitialValues = {U0Dynamic, V0Dynamic, A0Dynamic};
    
    if(strcmp(timeIntegration, 'Central Difference'))
        solutionQuantities = cdmDynamicSolver(problem, solutionPointer, globalMatrices, globalInitialValues);
    elseif(strcmp(timeIntegration, 'Newmark Integration'))
        solutionQuantities = newmarkDynamicSolver(problem, solutionPointer, globalMatrices, globalInitialValues);
    else
        error('timeIntegration is not correct.');
    end

end