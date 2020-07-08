function [ ret ] = moParseScalarWithoutWarning( name, struct, default )
% moParseScalar Extracts a scalar from a structure array by name without warning.
%
% ret = moParseScalarWithoutWarning(name, struct, default)
% extracts the field name from sthe structure arrray struct. If it is not
% defined or it is not a scalar, ret is set to default.

    ret = default;
    if isfield(struct,name) && isscalar(struct.(name))
        ret = struct.(name);
    end

end

