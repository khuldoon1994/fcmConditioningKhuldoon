# Global Operations

This directory contains functions that work on the (global) problem data structure but do not change it. Instead, generated data is returned in different (simple) data structures.

## Files in core/globalOperations

### goCreateElementMatrices.m
Creates all element matrices (stiffness matrix, right hand side or load vector and location vector).

```matlab
[allKe, allFe, allLe] = goCreateElementMatrices(problem);
```
The returned data structures are cell arrays of (dense) matrices.

### goCreateAndAssemblePenaltyMatrices.m
Creates the global penalty stiffness matrix $`\mathbf{K}_p`$ and global penalty force vector $`\mathbf{F}_p`$.

```matlab
[Kp, Fp] = goCreateAndAssemblePenaltyMatrices(problem)
```

### goCreateDynamicElementMatrices.m
The dynamic version of *goCreateElementMatrices.m*. Includes mass and damping matrices.
```matlab
[allMe, allDe, allKe, allFe, allLe] = goCreateDynamicElementMatrices(problem);
```

### goAssembleSolveDisassemble.m 
Performs the three steps indicated by its name.

## Subdirectories in core/globalOperations
#### assembly
Functions for the assembly (and disassembly) of element matrices.

### dynamic
Functions for the dynamic analysis.

### plotting 
Functions for plotting the solution.

### postProcessing
Functions for post processing tasks.
