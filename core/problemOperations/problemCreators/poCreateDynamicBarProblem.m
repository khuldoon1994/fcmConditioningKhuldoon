function [ problem ] = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, n, f, tStart, tStop, nTimeSteps)
% Creates a ready to use problem data structure. An elastic bar with Youngs
% modulus E, area A, mass density rho, damping coefficient kappa and 
% length L is discretized with n elements with shape
% functions of order p (integrated Legendre polynomials). It is loaded by a
% distributed force f, which can be a function handle.
%
% tStart < t < tStop
% nTimeSteps is the number of time samples
    
    if nargin < 1
        E = 1;
    end
    if nargin < 2
        A = 1;
    end
    if nargin < 3
        rho = 1;
    end
    if nargin < 4
        % no damping
        kappa = 0;
    end
    if nargin < 5
        L = 1;
    end
    if nargin < 6
        % quadratic shape functions
        p = 2;
    end
    if nargin < 7
        % one element
        n = 1;
    end
    if nargin < 8
        f = @(x)( x/L );
    end
    if nargin < 9
        tStart = 0;
    end
    if nargin < 10
        tStop = 10;
    end
    if nargin < 11
        nTimeSteps = 1001;
    end
    
    %% problem definition
    problem.name = 'dynamicBar1D';
    problem.dimension = 1;
    
    % subelement types
    subelementTypeData.order = p;
    subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', subelementTypeData );
    problem.subelementTypes = { subelementType1 };
    
    % element types
    elementTypeData1 = struct( 'gaussOrder', p+1, 'youngsModulus', E, 'area', A, 'massDensity', rho, 'dampingCoefficient', kappa );
    elementType1 = poCreateElementType( 'DYNAMIC_LINE_1D', elementTypeData1 );
    problem.elementTypes = { elementType1 };
    
    % nodes
    problem.nodes = linspace(0,L,n+1);
    
    % elements
    problem.elementTypeIndices = ones(1,n);
    problem.elementTopologies = ones(1,n);
    problem.elementNodeIndices = cell(1,n);
    for i=1:n
        problem.elementNodeIndices{i} = [ i i+1 ];
    end
    
    % subelements
    problem.subelementTypeIndices = ones(1,n);
    problem.subelementTopologies = ones(1,n);
    problem.subelementNodeIndices = cell(1,n);
    for i=1:n
        problem.subelementNodeIndices{i} = [ i i+1 ];
    end
    
    % connection / transformation between elements and subelements
    problem.elementConnections = cell(n,1);
    for i=1:n
        problem.elementConnections{i} = { { i 1 } };
    end
    % this can also be done fully automatically
    %problem.cellElementConnections = createCellElementConnections( problem );
    
    % boundary conditions
    problem.loads = { f };
    problem.penalties = { [0, E*1e15] };
    problem.foundations = { };
    
    % element boundary condition connections
    problem.elementLoads = cell(1,n);
    for i=1:n
        problem.elementLoads{i} = 1;
    end
    
    problem.elementPenalties = cell(1,n);
    problem.elementFoundations = cell(1,n);
    
    % nodal boundary condition connections
    problem.nodeLoads = cell(1,n+1);
    problem.nodePenalties = cell(1,n+1);
    problem.nodePenalties{1} = 1;
    problem.nodeFoundations = cell(1,n+1);
    
    % linear Dynamics
    problem.dynamics.timeIntegration = 'Central Difference';
    problem.dynamics.lumping = 'No Lumping';
    problem.dynamics.tStart = tStart;
    problem.dynamics.tStop = tStop;
    problem.dynamics.nTimeSteps = nTimeSteps;
    
    % check problem data structure
    problem = poCheckProblem(problem);
    
    % initialize dynamic problem
    problem = poInitializeDynamicProblem(problem);
    
end