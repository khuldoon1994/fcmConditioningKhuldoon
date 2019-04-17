function goPlotMesh( problem, fig )

    figure(fig);
    grid on;
    hold on;
    
    %% stuff for the legend
    nElementTypes = numel(problem.elementTypes);
    handles = zeros(1,nElementTypes+4);
    names = cell(1,nElementTypes+4);
    for iType = 1:nElementTypes
        names{iType} = problem.elementTypes{iType}.name;
    end
    names{nElementTypes+1} = 'NODES';
    names{nElementTypes+2} = 'LOADS';
    names{nElementTypes+3} = 'NODAL PENALTIES';
    names{nElementTypes+4} = 'ELEMENT PENALTIES';
    
    %% plot elements
    nElements=numel(problem.elementTypeIndices);
    for iElement=1:nElements
      elementTypeIndex = problem.elementTypeIndices(iElement);
      elementPlotter = problem.elementTypes{elementTypeIndex}.elementPlotter;
      handles(elementTypeIndex) = elementPlotter(problem, iElement);
    end

    %% plot nodes
    nNodes = size(problem.nodes,2);
    fullNodes = zeros(3,nNodes);
    fullNodes(1:problem.dimension,:) = problem.nodes;
    handles(nElementTypes+1) = plot3( fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), 'k.', 'markers', 15 );
    
    handles(nElementTypes+2) = quiver3(NaN,NaN,NaN, NaN,NaN,NaN, 'Color','red','LineWidth',2,'MaxHeadSize',1);
    handles(nElementTypes+3) = plot(NaN,NaN,'ro', 'markers', 10, 'linewidth', 2 );
    handles(nElementTypes+4) = plot(NaN,NaN,'rx','LineWidth',2, 'markers', 10);
    
    %% create legend    
    names(handles==0) = {};
    handles(handles==0) = [];
    
    if verLessThan('matlab', '9.2')
        legend(handles, names,  'Interpreter', 'none');
    else
        legend(handles, names,  'Interpreter', 'none', 'AutoUpdate', 'off');
    end
    
    axis equal;

end