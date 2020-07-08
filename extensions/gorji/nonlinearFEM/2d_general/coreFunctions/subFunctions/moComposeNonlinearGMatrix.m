function [ G ] = moComposeNonlinearGMatrix(dNdX)

    dim = size(dNdX,1);
    nShapes = size(dNdX,2);
    
    G = zeros(dim*dim, dim*nShapes);
    
    for i = 1:dim
        rows = (i-1)*dim + [1:dim];
        cols = i:dim:dim*nShapes;
        for j = 1:dim
            G(rows(j),cols) = dNdX(i,:);
        end
    end

end