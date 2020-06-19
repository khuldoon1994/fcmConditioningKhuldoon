TODO: Correct and cleanup
# Post processing #
Post processing in *SiHoFemLab* is so far something you have to care about yourself. However, some convenient routines are provided for the most common tasks.

## Computing something at a point within an element ##
Say you have an element $`e`$ and you want to compute something at the local element coordinates $`\mathbf{r}`$. Given the element degree of freedom solution vector $`\mathbf{u}_e`$ you can compute pretty much everything using standard functions.
Recalling the standard finite element ansatz, i.e. the interpolation of the solution by

$` \mathbf{u} = \sum_{i=1}^{n_\mathrm{shapes}} N_e^i(\mathbf{r}) \, \mathbf{u}_e^{i} = \mathbf{N}_e \, \mathbf{u}_e `$

and of the solution gradient by

$` \frac{\partial \mathbf{u}}{\partial \mathbf{x}} = \sum_{i=1}^{n_\mathrm{shapes}} \mathbf{u}_e^{i} \left( \frac{\partial N^{i}_e}{\partial \mathbf{X}} \right)^{\!\!\mathrm{T}}`$

using shape function $`N^{(i)}_e`$, the corresponding code should be quite intuitive:

```matlab
    % given: problem, Ue, e, r

    % interpolation matrix
    shapes = eoEvaluateShapeFUnctions(problem, e, r);
    % strain displacement matrix
    shapeDerivatives = eoEvaluateShapeFunctionGlobalDerivatives(problem, e, r);

    % You may use matlab functions such as reshape and arrayfun for an efficient
    % computation of what you want. Alternatively, use something like
    B = moComposeStrainDisplacementMatrix(shapeDerivatives);
    N = moComposeInterpolationMatrix(problem.dimension, shapes);

    u = N * Ue;
    strain = B * Ue;

    dudx = 0;
    for i=1:numel(shapes)
      dudx = dudx + U(shapeDerivatives(:,i)
    end
```

With the solution and the solution gradient, you can compute pretty much everything in a linear static analysis.

## Computing integrals over an element ##
There are two convenient function for integrating something over an element, one for integrating solution independent and one for integrating solution dependent functions.

```matlab
  fun1 = @(problem, e, r, x, J, detJ) x^2
  int1 = eoIntegrateFunction(problem, e, func1);

  int2 = eoIntegrateSolutionFunction(problem, e, Ue, func2);

  function sed = func2(problem, e, r, x, J, detJ, Ue)
    shapes = eoEvaluateShapeFUnctions(problem, e, r);
    B = moComposeStrainDisplacementMatrix(shapeDerivatives);
    C = eoEvaluateElasticityMatrix(problem, elementIndex, r);
    strain = B*Ue:
    sed = 0.5* straing' * C * strain;
  end
```

##  Files in core/globalOperations/postProcessing/ ##

### Readme.md ###
This file.

### goCreatePostGrid.m ###
Creates a post grid to be used for a more detailed (not only nodal values) evaluation of the solution.

### goComputeLinearStrainEnergy.m ###
