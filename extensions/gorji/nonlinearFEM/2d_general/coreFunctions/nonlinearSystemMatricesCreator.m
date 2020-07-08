function [ KTe, Re ] = nonlinearSystemMatricesCreator(problem, elementIndex, Ue)
% standardSystemMatricesCreator creates the linear elastic stiffness matrix
% and load vector for an n-dimensional continuum element.

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    elementType = problem.elementTypes{elementTypeIndex};
    
    % initialize matrices
    KTe = zeros(nDof,nDof);
    fe_int = zeros(nDof,1);
    fe_ext = zeros(nDof,1);
    Re = zeros(nDof,1);

    % create copy of function handles for shorter notation
    quadraturePointGetter = elementType.quadraturePointGetter;
    elasticityMatrixGetter = elementType.elasticityMatrixGetter;
%     constitutiveEquationGetter = ...;

    % helper functions

    % gather dimension related quantities
    if (elementType.localDimension == 2)
        thickness = elementType.thickness;
    elseif (elementType.localDimension == 1)
        area = elementType.area;
    end
    
    % create quadrature points
    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
    nPoints = numel(weights);

    % loop over quadrature points
    for i=1:nPoints
        
        % copy the local coordinates of this quadrature point
        localCoordinates = points(:,i);
        
        % shape functions and mapping evaluation
        shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, localCoordinates);
        shapeFunctionGlobalDerivatives = eoEvaluateShapeFunctionGlobalDerivative(problem,elementIndex,localCoordinates);
        jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates);
        detJ = det(jacobian);
        
        % simplify integrand
        if (elementType.localDimension == 2)
            detJ = detJ * thickness;
        elseif (elementType.localDimension == 1)
            detJ = detJ * area;
        end
        
        % continuum mechanics quantities
        dNdX = shapeFunctionGlobalDerivatives;
        G = moComposeNonlinearGMatrix(dNdX);
        voigtGradUe = G*Ue;
        GradUe = fromVoigt(voigtGradUe);
        F = deformationGradient(problem, GradUe);
        E = greenLagrangeStrain(problem, F);
        B = moComposeNonlinearBMatrix(dNdX, F);
        C = elasticityMatrixGetter(problem, elementIndex, localCoordinates);
        voigtS = C*B*Ue;
        S = fromVoigtS(voigtS);
        fullS = moComposeStressMatrix(S);
        
        % add tangent matrix integrand
        materialStiffness = B'*C*B * weights(i) * detJ;
        geometricStiffness = G'*fullS*G * weights(i) * detJ;        
        KTe = KTe + materialStiffness + geometricStiffness;
        
        % add internal load vector integrand
        fe_int = fe_int + B'*voigtS * weights(i) * detJ;
        
        % add external load vector integrand
        N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
        b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
        fe_ext = fe_ext + N'*b * weights(i) * detJ;
        
%         % add elastic foundation integrand
%         c = eoEvaluateTotalFoundationStiffness(problem, elementIndex, localCoordinates);
%         Ke = Ke + N'* c * N * weights(i) * detJ;
    end
    
    Re = fe_int - fe_ext;
   
end
