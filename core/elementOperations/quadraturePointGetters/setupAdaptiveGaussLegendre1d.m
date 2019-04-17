%TODO HUBI: Cleanup, Documentation, Optimization possible?
function elementQuadraturePoint = setupAdaptiveGaussLegendre1d( problem, elementIndex )
%eoSetupGaussLegendre1d Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};


%% quadrature point getter data
gaussOrder = elementType.quadraturePointGetterData.gaussOrder;
alphaFCM = elementType.quadraturePointGetterData.alphaFCM;
levelSetFunction = elementType.quadraturePointGetterData.levelSetFunction;

%% setup spacetree used for integration
lineTree = eoSetupLineTree(problem, elementIndex);
elementQuadraturePoint.spaceTree = lineTree;

brokenElements = lineTree.brokenElements; % list of elements
insideElements = lineTree.insideElements; % list of elements

%% setup quadrature points
nPoints = ceil( (gaussOrder+1)/2 );
[xg, wg] = moGetGaussLegendreQuadraturePoints( nPoints ); %%%%Achtung 2D

points = [];
weights = [];

% loop over inside elements
if ~isempty(insideElements)
    for i=1:length(insideElements)
        iElement = insideElements{i};
        % map points and weights
        Rmin = iElement.nodesMinMax(1);
        Rmax = iElement.nodesMinMax(2);
        tmpPoints = lineTree.mappingEvaluator(Rmin, Rmax, xg);
        tmpWeights = wg * lineTree.determinant(Rmin, Rmax);
        points = [points, tmpPoints];
        weights = [weights, tmpWeights];
    end
end

% loop over broken elements
if ~isempty(brokenElements)
    for i=1:length(brokenElements)
        iElement = brokenElements{i};
        % map points and weights
        Rmin = iElement.nodesMinMax(1);
        Rmax = iElement.nodesMinMax(2);
        % tmpPoints is within range [-1 1]
        tmpPoints = lineTree.mappingEvaluator(Rmin, Rmax, xg);
        
       for i=1:length(tmpPoints)
        tmpGlobalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, tmpPoints(i));
       end
        tmpEvaluatedGlobalPoints = levelSetFunction(tmpGlobalPoints);
        
        tmpWeights = wg * lineTree.determinant(Rmin, Rmax);
        
        checkGlobalPointsInside = (tmpEvaluatedGlobalPoints <= 0);
        if ~isempty(checkGlobalPointsInside)
            % tmpPoints is within range [-1 1]
            tmpPointsInside = tmpPoints + 100*checkGlobalPointsInside;
            tmpPointsInside = tmpPointsInside(tmpPointsInside > 90);
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
    for i=1:length(tmpPoints)
    tmpGlobalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, tmpPoints(i));
    end
    tmpEvaluatedGlobalPoints = levelSetFunction(tmpGlobalPoints);
    
    checkGlobalPointsOutside = (tmpEvaluatedGlobalPoints > 0);
    if ~isempty(checkGlobalPointsOutside)
        % tmpPoints is within range [-1 1]
        tmpPointsOutside = tmpPoints + 100*checkGlobalPointsOutside;
        tmpPointsOutside = tmpPointsOutside(tmpPointsOutside > 90);
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

end

