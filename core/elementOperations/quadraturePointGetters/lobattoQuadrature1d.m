function [ points, weights ] = lobattoQuadrature1d( problem, elementIndex )

    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    elementType = problem.elementTypes{elementTypeIndex};
    data = elementType.quadraturePointGetterData;

    order = moParseScalar('gaussOrder', data, 2, ['quadrature getter data for element type ',elementType.name]);
    
    [points, weights ] = moGetGaussLobattoQuadraturePoints(order);
   
end    