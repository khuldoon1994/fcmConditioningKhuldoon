function [ newType ] = poCreateElementType(  typeName, typeData )
% poCreateElementType Adds a standard (or dynamic, FCM, etc.) element type by name.
%   
%   newType = poCreateElementType(typeName, typeData) craetes a new
%   element type with name typeName according to the parameters given in
%   typeData.
%
%   typeName must be a character array representing a known type name.
%   typeData must be a structure array with fields as expected by the type.
%
%   See also poCreateElementTypeStandardLine1d,
%   poCreateElementTypeStandardLine2d, poCreateElementTypeStandardQuad2d,

    names = { 'STANDARD_LINE_1D', ...
              'STANDARD_LINE_2D', ...
              'STANDARD_QUAD_2D', ...
              'FCM_LINE_1D', ...
              'STANDARD_POINT_2D', ...
              'STANDARD_TRUSS_2D' };
    creators = { @poCreateElementTypeStandardLine1d, ...
                 @poCreateElementTypeStandardLine2d, ...
                 @poCreateElementTypeStandardQuad2d, ...
                 @poCreateElementTypeFCMLine1d, ...
                 @poCreateElementTypeStandardPoint2d, ...
                 @poCreateElementTypeStandardTruss2d };
            
    iType = find(strcmp(names,typeName));
             
    if isscalar(iType)
        newType = creators{iType}(typeData);
    else
        disp(['ERROR! Element type name ', typeName, ' is unknown. Choose one of ']);
        disp(names);
    end

end

