function [ quantityDynamic ] = goChooseQuantity(UDynamic, VDynamic, ADynamic, quantityName)
    %choose right quantity from string
    
    switch quantityName
        case 'displacement'
            quantityDynamic = UDynamic;
        case 'velocity'
            quantityDynamic = VDynamic;
        case 'acceleration'
            quantityDynamic = ADynamic;
        otherwise
            error('quantityName must be either "displacement", "velocity" or "acceleration"');
    end
end