function [ ret ] = moParseString( name, struct, default, structName )
% moParseString Extracts a string from a structure array by name or warns.
%
% ret = moParseScalar(name, struct, default, structName) extracts the field
% name from sthe structure arrray struct. If it does not exist or is not a
% string, a warning is printed, where structName is used to denote the
% structure array. In these cases, ret is set to default.

    ret = default;
    if ~isfield(struct,name)
        warning(['WARNING! No field "',name,'" given in ',structName,'. Assuming ',num2str(default),'.']);
    else
        if ~ischar(struct.(name))
            warning(['WARNING! Field "',name,'" in ',structName,' is not a string. Assuming ',num2str(default),'.']);
        else
            ret = struct.(name);
        end
    end

end

