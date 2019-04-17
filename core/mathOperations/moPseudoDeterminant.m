function [ determinant ] = moPseudoDeterminant( matrix )
%pseudoDeterminant Computes the pseudo determinant for non-square matrices

    if size(matrix,1) == size(matrix,2)
       determinant = det(matrix);
    elseif size(matrix,1) > size(matrix,2)
        determinant = sqrt(det(matrix'*matrix));
    else
        determinant = sqrt(det(matrix*matrix'));
    end

    
end

