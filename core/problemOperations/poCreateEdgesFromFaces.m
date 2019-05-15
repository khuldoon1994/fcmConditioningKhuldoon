function [ edgeNodeIndices ] = poCreateEdgesFromFaces( problem )
    
    nElements = numel(problem.elementTopologies);

    nEdges=0;

    for i=0:nElements
       if elementTopologyTypes~=2 % not QUAD
            continue;
       end

       elementNodeIndices = problem.elementNodeIndices{i};
        for j=0:4
        {
            localNodes = getQuadEdgeNodeIndices(j);
            extract(localNodes,elementNodeIndices,edgeOrdered);
            std::sort(edgeOrdered.begin(), edgeOrdered.end());

            int found=-1;
            for(Size e=0; e<nEdges; e++)
            {
                if(   edgesOrdered[e*2+0]==edgeOrdered[0]
                      && edgesOrdered[e*2+1]==edgeOrdered[1])
                {
                    found=e;
                    break;
                }
            }

            if(found<0)
            {

                edgesOrdered.push_back(edgeOrdered[0]);
                edgesOrdered.push_back(edgeOrdered[1]);

                nEdges++;

                elementTopologyTypes_.push_back(TopologyType::LINE);
                elementNodeIndices_.push_back(extract(localNodes,elementNodeIndices));
                elementVertices_.push_back({ });
            }
        }
    }

    LOG << "Created " << nEdges-nEdgesInitially << " edges automatically.\n";

end

