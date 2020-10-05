function elementQuadraturePoint = setupMomentFittingGaussLegendre1d( problem, elementIndex )
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};

gaussOrder = elementType.quadraturePointGetterData.gaussOrder;
alphaFCM = elementType.quadraturePointGetterData.alphaFCM;
levelSetFunction = elementType.quadraturePointGetterData.levelSetFunction;

%% setup spacetree used for integration

%quadTree = eoSetupQuadTree(problem, elementIndex);
quadTree = isElementCutByDomainBoundary(problem, elementIndex);

%problem.elementQuadratures{elementIndex}.spaceTree = quadTree;

brokenElements = quadTree.brokenElements; % list of elements
insideElements = quadTree.insideElements; % list of elements
outsideElements = quadTree.outsideElements; % list of elements

%%
[xg1d, wg1d] = gaussLegendre1d( gaussOrder );
[X, Y] = meshgrid(xg1d, xg1d);

xg(1,:) = X(:)';
xg(2,:) = Y(:)';
wg = kron(wg1d,wg1d);

points = [];
weights = [];

%%
pointsIn1D = xg1d;
numberOfPointsIn1D = size(xg1d,2);
spaceDim = 2;

maxDimR = numberOfPointsIn1D * ( spaceDim >= 1 );
maxDimS = numberOfPointsIn1D * ( spaceDim >= 2 ) + ( spaceDim < 2 );

numberOfMomentFittingPoints = maxDimR * maxDimS;

%% initialize Lagrange basis
evaluatedLagrangePolynomialsR = zeros(1,maxDimR);
evaluatedLagrangePolynomialsS = zeros(1,maxDimS);

%%    
% apply standard gauss quadrature for non broken cells 
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

% apply moment fitting for broken cells
if ~isempty(brokenElements)
    for i=1:length(brokenElements)
        iElement = brokenElements{i};
        % map points and weights
        Rmin = iElement.nodesMinMax(:,1);
        Rmax = iElement.nodesMinMax(:,2);
        % tmpPoints is within range [-1 1]x[-1,1]
        tmpPoints = quadTree.mappingEvaluator(Rmin, Rmax, xg);
        
        % Compute the moment fitting weights using the octree  
        elementQuadraturePoint = eoSetupAdaptiveGaussLegendre2d( problem, 1 );
        
        %tmpWeights = wg * quadTree.determinant(Rmin, Rmax);
        tmpWeights = zeros(size(wg));
        
        points_ = elementQuadraturePoint.points;
        weights_ = elementQuadraturePoint.weights;
        
        for index = 1:size(points_,2)
            % Evaluate Lagrange basis function at integration point
            evaluatedLagrangePolynomialsR = lagrangeBasis( pointsIn1D, points_(1,index), maxDimR, evaluatedLagrangePolynomialsR );
            evaluatedLagrangePolynomialsS = lagrangeBasis( pointsIn1D, points_(2,index), maxDimS, evaluatedLagrangePolynomialsS );

            counter = 1;

            for rBasis = 1:maxDimR
                for sBasis = 1:maxDimS
                    tmpWeights(counter) = tmpWeights(counter) + evaluatedLagrangePolynomialsR(1, rBasis)*evaluatedLagrangePolynomialsR(1, sBasis) * weights_(index);
                    counter = counter+1;
                end
            end
        end
        
        points = [points, tmpPoints];
        weights = [weights, tmpWeights];
        
    end
end

% add stablization points in the fictitious domain
if alphaFCM > 0.0
    tmpPoints = xg;
    tmpWeights = wg;
    tmpGlobalPoints = zeros(size(tmpPoints));
    for j=1:length(tmpPoints(1,:))
        tmpGlobalPoints(:,j) = elementType.mappingEvaluator(problem, elementIndex, tmpPoints(:,j));
    end
    tmpEvaluatedGlobalPoints = problem.elementTypes{elementTypeIndex}.quadraturePointGetterData.levelSetFunction(tmpGlobalPoints);
    
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
        weights = [weights, tmpWeightsOutside*alphaFCM];
    end
end

elementQuadraturePoint.points = points;
elementQuadraturePoint.weights = weights;

elementQuadraturePoint.spaceTree = quadTree;

end