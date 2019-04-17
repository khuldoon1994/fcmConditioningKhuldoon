function [ inverse ] = moPseudoInverse( matrix )
%pseudoInverse Computes the pseudo inverse for non-square matrices

if size(matrix,1) == size(matrix,2)
   inverse = inv(matrix);
elseif size(matrix,1) > size(matrix,2)
    inverse = inv(matrix' * matrix) * matrix'; %#ok
else
    inverse = matrix' * inv(matrix * matrix'); %#ok
end

end

