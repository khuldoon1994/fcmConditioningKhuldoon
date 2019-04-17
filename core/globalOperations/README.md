<h1>Global Operations</h1>

This directory contains functions that work on the (global) problem data structure but do not change it. Instead, generated data is returned in different (simple) data structures.

<h2> Files in core/globalOperations</h2>

<h3> goCreateElementMatrices.m </h3>
Creates all element matrices (stiffness matrix, right hand side or load vector and location vector).
<pre><code>
[allKe, allFe, allLe] = goCreateElementMatrices(problem);
</code></pre>
The returned data structures are cell arrays of (dense) matrices.

<h3> goCreateAndAssemblePenaltyMatrices.m </h3>
Creates the global penalty stiffness matrix **Kp** and global penalty force vector **Fp**.
<pre><code>
[Kp, Fp] = goCreateAndAssemblePenaltyMatrices(problem)
</code></pre>

<h3> goCreateDynamicElementMatrices.m </h3>
The dynamic version of _goCreateElementMatrices.m_
<pre><code>
[allMe, allDe, allKe, allFe, allLe] = goCreateDynamicElementMatrices(problem);
</code></pre>

<h3> goAssembleSolveDisassemble.m </h3>
Performs the three steps indicated by its name.

<h2> Subdirectories in core/globalOperations</h2>
<h3> assembly </h3>
Functions for the assembly (and disassembly) of element matrices.

<h3> dynamic </h3>
Functions for the dynamic analysis.

<h3> plotting </h3>
Functions for plotting the solution.

<h3> postProcessing </h3>
Functions for post processing tasks.
