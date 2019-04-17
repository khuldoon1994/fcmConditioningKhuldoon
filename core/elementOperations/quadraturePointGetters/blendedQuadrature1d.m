function [ points, weights ] = blendedQuadrature1d( problem, elementIndex )

    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    elementType = problem.elementTypes{elementTypeIndex};
    data = elementType.quadraturePointGetterData;

    order = moParseScalar('gaussOrder', data, 2, ['quadrature getter data for element type ',elementType.name]);
    
    [points, weights ] = moGetBlendedQuadraturePoints(order);
   
end