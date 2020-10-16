function geometryInfo = isElementCutByDomainBoundary2D( problem, elementIndex )
%eoSetupQuadTree Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};

%% initialize testpoints

r = linspace(-0.999, 0.999, 3);
[X, Y] = meshgrid(r,r);
testPoints = [ X(:)' ; Y(:)'];

%% initialize quadtree

geometryInfo.mappingEvaluator =@(Rmin, Rmax, testPoints) Rmin + (1 + testPoints).*(Rmax - Rmin)/2;
geometryInfo.determinant =@(Rmin, Rmax) (Rmax(1) - Rmin(1))/2 * (Rmax(2) - Rmin(2))/2;

geometryInfo.insideElements = {}; % list of elements
geometryInfo.outsideElements = {}; % list of elements
geometryInfo.brokenElements = {}; % list of elements

%% setup quadtree
Rmin = [-1 ; -1]; Rmax = [1 ; 1];
quadElement.nodesMinMax = [Rmin , Rmax];

localPoints = geometryInfo.mappingEvaluator(Rmin, Rmax, testPoints);
globalPoints = zeros(size(localPoints));

for i=1:length(localPoints)
    globalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, localPoints(:,i));
end

evaluatedGlobalPoints = problem.elementTypes{elementTypeIndex}.quadraturePointGetterData.levelSetFunction(globalPoints);

checkPoints = evaluatedGlobalPoints > 0;
if sum(checkPoints) == 0
    quadElement.status = 'isInside';
    geometryInfo.insideElements{end+1} = quadElement;
elseif (sum(checkPoints) > 0) && (sum(checkPoints) == length(testPoints))
    quadElement.status = 'isOutside';
    geometryInfo.outsideElements{end+1} = quadElement;
else
    quadElement.status = 'isBroken';
    geometryInfo.brokenElements{end+1} = quadElement;
end

end

