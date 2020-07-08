function [ fullS ] = moComposeStressMatrix(S)

    dim = size(S,1);
    fullS = [];
    
    for i = 1:dim
        fullS = blkdiag(fullS, S');
    end

end