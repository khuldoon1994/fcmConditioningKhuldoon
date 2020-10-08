function status = isCellBroken2D( problem, elementIndex )
%eoSetupQuadTree Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};

%% initialize testpoints

r = linspace(-0.999, 0.999, 3);
[X, Y] = meshgrid(r,r);
testPoints = [ X(:)' ; Y(:)'];

%% initialize quadtree

mappingEvaluator =@(Rmin, Rmax, testPoints) Rmin + (1 + testPoints).*(Rmax - Rmin)/2;
%determinant =@(Rmin, Rmax) (Rmax(1) - Rmin(1))/2 * (Rmax(2) - Rmin(2))/2;


%% setup quadtree
Rmin = [-1 ; -1]; Rmax = [1 ; 1];

localPoints = mappingEvaluator(Rmin, Rmax, testPoints);
globalPoints = zeros(size(localPoints));

for i=1:length(localPoints)
    globalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, localPoints(:,i));
end

evaluatedGlobalPoints = problem.elementTypes{elementTypeIndex}.quadraturePointGetterData.levelSetFunction(globalPoints);

checkPoints = evaluatedGlobalPoints > 0;
if sum(checkPoints) == 0
    status = 'isInside';
elseif (sum(checkPoints) > 0) && (sum(checkPoints) == length(testPoints))
    status = 'isOutside';
else
    status = 'isBroken';
end

end

