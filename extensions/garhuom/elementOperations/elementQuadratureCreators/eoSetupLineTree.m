function lineTree = eoSetupLineTree( problem, elementIndex )
%EOSETUPLINETREE Summary of this function goes here
%   Detailed explanation goes here

elementTypeIndex = problem.elementTypeIndices(elementIndex);
elementType = problem.elementTypes{elementTypeIndex};

%% initialize testpoints

testPoints = linspace(-0.999, 0.999, 3);

%% initalize linetree

lineTree.mappingEvaluator =@(Rmin, Rmax, testPoints) Rmin + (1 + testPoints).*(Rmax - Rmin)/2;
lineTree.determinant =@(Rmin, Rmax) (Rmax - Rmin)/2;

lineTree.insideElements = {}; % list of elements
lineTree.outsideElements = {}; % list of elements
lineTree.brokenElements = {}; % list of elements

%% setup linetree

tmpElements = {};
treeDepthLevel = problem.elementTypes{elementTypeIndex}.quadraturePointGetterData.depth;
for iLevel=0:treeDepthLevel
    
    % initialize root of line tree
    if iLevel == 0
        lineElement.treeDepthLevel = iLevel;
        Rmin = -1; Rmax = 1;
        lineElement.nodesMinMax = [Rmin Rmax];
        
        localPoints = lineTree.mappingEvaluator(Rmin, Rmax, testPoints);
        %globalPoints=zeros(1,length(localPoints));
        for i=1:length(localPoints)
        globalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, localPoints(i)); % for loop added for 2D
        end
        evaluatedGlobalPoints = problem.elementTypes{elementTypeIndex}.quadraturePointGetterData.levelSetFunction(globalPoints);
        
        checkPoints = evaluatedGlobalPoints > 0;
        if sum(checkPoints) == 0
            lineElement.status = 'isInside';
            lineTree.insideElements{end+1} = lineElement;
        elseif (sum(checkPoints) > 0) && (sum(checkPoints) == length(testPoints))
            lineElement.status = 'isOutside';
            lineTree.outsideElements{end+1} = lineElement;
        else
            lineElement.status = 'isBroken';
            tmpElements{end+1} = lineElement;
        end
    end
    
    if isempty(tmpElements)
        break;
    end

    tmpBrokenElements = {};
    if iLevel > 0 && ~isempty(tmpElements)
        for iE=1:length(tmpElements)
            tmpElement = tmpElements{iE};
            Rmin = tmpElement.nodesMinMax(1);
            Rmax = tmpElement.nodesMinMax(2);
            dR = (Rmax - Rmin) / 2;
            
            lineElement1.treeDepthLevel = iLevel;
            lineElement1.nodesMinMax = [Rmin Rmin+dR];
            
            lineElement2.treeDepthLevel = iLevel;
            lineElement2.nodesMinMax = [Rmin+dR Rmax];
            
            list = {lineElement1 lineElement2};
            for j=1:2
                lineElement = list{j};
                Rmin = lineElement.nodesMinMax(1);
                Rmax = lineElement.nodesMinMax(2);
                localPoints = lineTree.mappingEvaluator(Rmin, Rmax, testPoints);
                for i=1:length(localPoints)
                globalPoints(:,i) = elementType.mappingEvaluator(problem, elementIndex, localPoints(i));
                end
                evaluatedGlobalPoints = problem.elementTypes{elementTypeIndex}.quadraturePointGetterData.levelSetFunction(globalPoints);
                
                checkPoints = evaluatedGlobalPoints > 0;
                if sum(checkPoints) == 0
                    lineElement.status = 'isInside';
                    lineTree.insideElements{end+1} = lineElement;
                elseif (sum(checkPoints) > 0) && (sum(checkPoints) == length(testPoints))
                    lineElement.status = 'isOutside';
                    lineTree.outsideElements{end+1} = lineElement;
                else
                    lineElement.status = 'isBroken';
                    tmpBrokenElements{end+1} = lineElement;
                end
            end
        end
        tmpElements = tmpBrokenElements;
    end
    
    if iLevel == treeDepthLevel
        lineTree.brokenElements = tmpElements;
    end
end



end

