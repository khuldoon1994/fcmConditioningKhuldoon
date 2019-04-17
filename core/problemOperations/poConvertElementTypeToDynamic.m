function [ newType ] = poConvertElementTypeToDynamic( oldType, typeData )
%converts an oldType element 'STANDARD_' to a newType element 'DYNAMIC_'
    
    %% parse input
    rho = moParseScalar('massDensity',typeData,1,'typeData for DYNAMIC_ELEMENT_TYPE');
    kappa = moParseScalar('dampingCoefficient',typeData,0,'typeData for DYNAMIC_ELEMENT_TYPE');
    
    %% create type
    newType = oldType;
    
    if(contains(char(oldType.name), 'STANDARD'))
    % convert from STANDARD to DYNAMIC
        %set name to DYNAMIC
        temp = char(oldType.name);
        newType.name = replace(temp, 'STANDARD', 'DYNAMIC');
        
        % set systemMatricesCreator to DYNAMIC
        temp = char(oldType.systemMatricesCreator);
        switch temp
            case 'standardSystemMatricesCreator'
                newType.systemMatricesCreator = @standardDynamicSystemMatricesCreator;
            case 'boundarySystemMatricesCreator'
                newType.systemMatricesCreator = @boundaryDynamicSystemMatricesCreator;
            otherwise
                error('error');
        end
        
        % set dynamic material
        newType.dynamicMaterialGetter = @linearDynamicMaterial;
        newType.dynamicMaterialGetterData.massDensity = rho;
        newType.dynamicMaterialGetterData.dampingCoefficient = kappa;
    else
        warning('oldType is not from type STANDARD');
    end
    
end

