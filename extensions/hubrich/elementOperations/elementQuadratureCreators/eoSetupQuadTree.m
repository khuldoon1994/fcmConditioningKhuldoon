function quadTree = eoSetupQuadTree( problem, elementIndex )
%eoSetupQuadTree Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};

%% initialize testpoints

r = linspace(-0.999, 0.999, 3);
[X, Y] = meshgrid(r,r);
testPoints = [ X(:)' ; Y(:)'];

%% initialize quadtree

quadTree.mappingEvaluator =@(Rmin, Rmax, testPoints) Rmin + (1 + testPoints).*(Rmax - Rmin)/2;
quadTree.determinant =@(Rmin, Rmax) (Rmax(1) - Rmin(1))/2 * (Rmax(2) - Rmin(2))/2;

quadTree.insideElements = {}; % list of elements
quadTree.outsideElements = {}; % list of elements
quadTree.brokenElements = {}; % list of elements

%% setup quadtree

tmpElements = {};
treeDepthLevel = problem.elementTypes{elementIndex}.quadraturePointGetterData.depth;
for iLevel=0:treeDepthLevel
    
    % initialize root of line tree
    if iLevel == 0
        quadElement.treeDepthLevel = iLevel;
        Rmin = [-1 ; -1]; Rmax = [1 ; 1];
        quadElement.nodesMinMax = [Rmin , Rmax];
        
        localPoints = quadTree.mappingEvaluator(Rmin, Rmax, testPoints);
        globalPoints = zeros(size(localPoints));
        for i=1:length(localPoints)
            globalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, localPoints(:,i));
        end
        evaluatedGlobalPoints = problem.elementTypes{elementIndex}.quadraturePointGetterData.levelSetFunction(globalPoints);
        
        checkPoints = evaluatedGlobalPoints > 0;
        if sum(checkPoints) == 0
            quadElement.status = 'isInside';
            quadTree.insideElements{end+1} = quadElement;
        elseif (sum(checkPoints) > 0) && (sum(checkPoints) == length(testPoints))
            quadElement.status = 'isOutside';
            quadTree.outsideElements{end+1} = quadElement;
        else
            quadElement.status = 'isBroken';
            tmpElements{end+1} = quadElement;
        end
    end
    
    if isempty(tmpElements)
        break;
    end

    tmpBrokenElements = {};
    if iLevel > 0 && ~isempty(tmpElements)
        for iE=1:length(tmpElements)
            tmpElement = tmpElements{iE};
            Rmin = tmpElement.nodesMinMax(:,1);
            Rmax = tmpElement.nodesMinMax(:,2);
            dR = (Rmax - Rmin) / 2;
            
            % subcell 1
            quadElement1.treeDepthLevel = iLevel;
            quadElement1.nodesMinMax = [[Rmin(1) ; Rmin(2)] , [Rmin(1)+dR(1) ; Rmin(2)+dR(2)]];
            
            % subcell 2
            quadElement2.treeDepthLevel = iLevel;
            quadElement2.nodesMinMax = [[Rmin(1)+dR(1) ; Rmin(2)] , [Rmax(1) ; Rmin(2)+dR(2)]];
            
            % subcell 3
            quadElement3.treeDepthLevel = iLevel;
            quadElement3.nodesMinMax = [[Rmin(1) ; Rmin(2)+dR(2)] , [Rmin(1)+dR(1) ; Rmax(2)]];
            
            % subcell 4
            quadElement4.treeDepthLevel = iLevel;
            quadElement4.nodesMinMax = [[Rmin(1)+dR(1) ; Rmin(2)+dR(2)] , [Rmax(1) ; Rmax(2)]];
            
            list = {quadElement1 quadElement2 quadElement3 quadElement4};
            for j=1:length(list)
                quadElement = list{j};
                Rmin = quadElement.nodesMinMax(:,1);
                Rmax = quadElement.nodesMinMax(:,2);
                localPoints = quadTree.mappingEvaluator(Rmin, Rmax, testPoints);
                globalPoints = zeros(size(localPoints));
                for i=1:length(localPoints)
                    globalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, localPoints(:,i));
                end
                evaluatedGlobalPoints = problem.elementTypes{elementIndex}.quadraturePointGetterData.levelSetFunction(globalPoints);
                
                checkPoints = evaluatedGlobalPoints > 0;
                if sum(checkPoints) == 0
                    quadElement.status = 'isInside';
                    quadTree.insideElements{end+1} = quadElement;
                elseif (sum(checkPoints) > 0) && (sum(checkPoints) == length(testPoints))
                    quadElement.status = 'isOutside';
                    quadTree.outsideElements{end+1} = quadElement;
                else
                    quadElement.status = 'isBroken';
                    tmpBrokenElements{end+1} = quadElement;
                end
            end
        end
        tmpElements = tmpBrokenElements;
    end
    
    if iLevel == treeDepthLevel
        quadTree.brokenElements = tmpElements;
    end
end


end

