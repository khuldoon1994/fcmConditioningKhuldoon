function [ newType ] = poCreateSubelementType( typeName, typeData )
% poCreateSubelementType Adds a standard element type by name.
%   
%   newType = poCreateSubelementType(typeName, typeData) craetes a new
%   subelement type with name typeName according to the parameters given in
%   typeData.
%
%   typeName must be a character array representing a known type name.
%   typeData must be a structure array with fields as expected by the type.
%
%   See also poCreateSubelementTypeLinearLine, 
%   poCreateSubelementTypeLinearQuad, poCreateSubelementTypeLegendreLine,
%   poCreateSubelementTypeLegendreQuad, poCreateSubelementTypeLegendreEdge


    names = { 'LINEAR_LINE', ...
              'LINEAR_QUAD', ...
              'LEGENDRE_LINE', ...
              'LEGENDRE_QUAD', ...
              'LEGENDRE_EDGE' };
          
    creators = { @poCreateSubelementTypeLinearLine, ...
                 @poCreateSubelementTypeLinearQuad, ...
                 @poCreateSubelementTypeLegendreLine, ...
                 @poCreateSubelementTypeLegendreQuad, ...
                 @poCreateSubelementTypeLegendreEdge };
            
    iType = find(strcmp(names,typeName));
             
    if isscalar(iType)
        newType = creators{iType}(typeData);
    else
        disp(['ERROR! Subelement type name ', typeName, ' is unknown. Choose one of ']);
        disp(names);
    end
    
end



