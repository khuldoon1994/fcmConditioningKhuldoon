function elementQuadraturePoint = eoSetupAdaptiveGaussLegendre2d( problem, elementIndex )
%eoSetupGaussLegendre2d Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};

gaussOrder = elementType.quadraturePointGetterData.gaussOrder;
alphaFCM = elementType.quadraturePointGetterData.alphaFCM;
levelSetFunction = elementType.quadraturePointGetterData.levelSetFunction;

%% setup spacetree used for integration

quadTree = eoSetupQuadTree(problem, elementIndex);
problem.elementQuadratures{elementIndex}.spaceTree = quadTree;

brokenElements = quadTree.brokenElements; % list of elements
insideElements = quadTree.insideElements; % list of elements
outsideElements = quadTree.outsideElements; % list of elements

%%

pq = gaussOrder;
ng1d = ceil( (pq+1)/2 );
[xg1d, wg1d] = gaussLegendre1d( ng1d );
[X, Y] = meshgrid(xg1d, xg1d);

xg(1,:) = X(:)';
xg(2,:) = Y(:)';
wg = kron(wg1d,wg1d);


points = [];
weights = [];

% loop over inside elements
if ~isempty(insideElements)
    for i=1:length(insideElements)
        iElement = insideElements{i};
        % map points and weights
        Rmin = iElement.nodesMinMax(:,1);
        Rmax = iElement.nodesMinMax(:,2);
        % tmpPoints is within range [-1 1]x[-1,1]
        tmpPoints = quadTree.mappingEvaluator(Rmin, Rmax, xg);
        tmpWeights = wg * quadTree.determinant(Rmin, Rmax);
        points = [points, tmpPoints];
        weights = [weights, tmpWeights];
    end
end

% loop over broken elements
if ~isempty(brokenElements)
    for i=1:length(brokenElements)
        iElement = brokenElements{i};
        % map points and weights
        Rmin = iElement.nodesMinMax(:,1);
        Rmax = iElement.nodesMinMax(:,2);
        % tmpPoints is within range [-1 1]x[-1,1]
        tmpPoints = quadTree.mappingEvaluator(Rmin, Rmax, xg);        
        tmpGlobalPoints = zeros(size(tmpPoints));
        for j=1:length(tmpPoints(1,:))
            tmpGlobalPoints(:,j) = elementType.mappingEvaluator(problem, elementIndex, tmpPoints(:,j));
        end
        
        tmpEvaluatedGlobalPoints = levelSetFunction(tmpGlobalPoints);
        
        tmpWeights = wg * quadTree.determinant(Rmin, Rmax);
        
        checkGlobalPointsInside = (tmpEvaluatedGlobalPoints <= 0);
        if ~isempty(checkGlobalPointsInside)
            % tmpPoints is within range [-1 1]
            tmpPointsInside = tmpPoints + 100*checkGlobalPointsInside;
            checkMatrix = tmpPointsInside > 90;
            tmpPointsInside = tmpPointsInside .* checkMatrix;
            x = tmpPointsInside(1,:);
            y = tmpPointsInside(2,:);
            x = x(x>90);
            y = y(y>90);
            tmpPointsInside = [x ; y];
            tmpPointsInside = tmpPointsInside - 100;
            points = [points, tmpPointsInside];
            
            tmpWeightsInside = tmpWeights + 100*checkGlobalPointsInside;
            tmpWeightsInside = tmpWeightsInside(tmpWeightsInside > 90);
            tmpWeightsInside = (tmpWeightsInside - 100);
            weights = [weights, tmpWeightsInside];
        end
    end
end


if alphaFCM > 0.0
    tmpPoints = xg;
    tmpWeights = wg;
    tmpGlobalPoints = zeros(size(tmpPoints));
    for j=1:length(tmpPoints(1,:))
        tmpGlobalPoints(:,j) = elementType.mappingEvaluator(problem, elementIndex, tmpPoints(:,j));
    end
    tmpEvaluatedGlobalPoints = problem.elementTypes{elementIndex}.quadraturePointGetterData.levelSetFunction(tmpGlobalPoints);
    
    checkGlobalPointsOutside = (tmpEvaluatedGlobalPoints > 0);
    if ~isempty(checkGlobalPointsOutside)
        % tmpPoints is within range [-1 1]
        tmpPointsOutside = tmpPoints + 100*checkGlobalPointsOutside;
        checkMatrix = tmpPointsOutside > 90;
        tmpPointsOutside = tmpPointsOutside .* checkMatrix;
        x = tmpPointsOutside(1,:);
        y = tmpPointsOutside(2,:);
        x = x(x>90);
        y = y(y>90);
        tmpPointsOutside = [x ; y];
        tmpPointsOutside = tmpPointsOutside - 100;
        points = [points, tmpPointsOutside];
        
        tmpWeightsOutside = tmpWeights + 100*checkGlobalPointsOutside;
        tmpWeightsOutside = tmpWeightsOutside(tmpWeightsOutside > 90);
        tmpWeightsOutside = (tmpWeightsOutside - 100);
        weights = [weights, tmpWeightsOutside];
    end
end

elementQuadraturePoint.points = points;
elementQuadraturePoint.weights = weights;

elementQuadraturePoint.spaceTree = quadTree;



end

