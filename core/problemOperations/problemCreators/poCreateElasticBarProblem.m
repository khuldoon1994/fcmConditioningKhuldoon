function [ problem ] = poCreateElasticBarProblem(E, A, L, p, n, f)
% Creates a ready to use problem data structure. An elastic bar with Youngs
% modulus E, area A and length L is discretized with n elements with shape
% functions of order p (integrated Legendre polynomials). It is loaded by a
% distributed force f, which can be a function handle.

    %% problem definition
    problem.name='elasticBar';
    problem.dimension = 1;

    % subelement types
    subelementTypeData.order = p;
    subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', subelementTypeData );
    problem.subelementTypes = { subelementType1 };

    % element types
    elementTypeData1 = struct('gaussOrder', p+1, 'youngsModulus', E, 'area', A);
    elementType1 = poCreateElementType( 'STANDARD_LINE_1D', elementTypeData1 );
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

    % check problem data structure
    problem = poCheckProblem(problem);


end