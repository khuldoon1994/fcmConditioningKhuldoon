function [ ret ] = moParseScalar( name, struct, default, structName )
% moParseScalar Extracts a scalar from a structure array by name or warns.
%
% ret = moParseScalar(name, struct, default, structName) extracts the field
% name from the structure array struct. If it does not exist or is not a
% scalar, a warning is printed, where structName is used to denote the
% structure array. In these cases, ret is set to default.

    ret = default;
    if ~isfield(struct,name)
        warning(['WARNING! No field "',name,'" given in ',structName,'. Assuming ',num2str(default),'.']);
    else
        if ~isscalar(struct.(name))
            warning(['WARNING! Field "',name,'" in ',structName,' is not a scalar. Assuming ',num2str(default),'.']);
        else
            ret = struct.(name);
        end
    end

end

