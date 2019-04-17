function [ full ] = moMakeFull( values, dimension, defaultValue )
% moMakeFull Adds additional rows to values.

    nValues = size(values,2);
    reducedDimension = size(values,1);
    full = ones(dimension, nValues)*defaultValue;
    full(1:reducedDimension,:) = values;

end

