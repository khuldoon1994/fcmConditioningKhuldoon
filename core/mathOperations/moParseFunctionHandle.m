function [ ret ] = moParseFunctionHandle( name, struct, default, structName )
% moParseFunctionHandle Extracts a function handle from a structure array 
% by name or warns.
%
% ret = moParseFunctionHandle(name, struct, default, structName) extracts 
% the field name from sthe structure arrray struct. If it does not exist or
% is not a function handle, a warning is printed, where structName is used
% to denote the structure array. In these cases, ret is set to default.

    ret = default;
    if ~isfield(struct,name)
        warning(['WARNING! No field "',name,'" given in ',structName,'. Assuming ',func2str(default),'.']);
    else
        if ~isa(struct.(name),'function_handle')
            warning(['WARNING! Field "',name,'" in ',structName,' is not a scalar. Assuming ',func2str(default),'.']);
        else
            ret = struct.(name);
        end
    end

end

