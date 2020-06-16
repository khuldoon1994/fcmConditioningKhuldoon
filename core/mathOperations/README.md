<h1>Math Operations</h1>

This directory contains simple functions, which are not naturally provided by MATLAB. 
Most of them are listed below, some of them are stored in two additional subdirectories.

<h2>Files in core/mathOperations/</h2>
<h3>README.md</h3>
This file


<h3>moContainsAll.m</h3>
Checks if all elements in the second argument (a matrix) are contained in the first argument (a matrix).

<h3>moCreateTransformation.m</h3>
Creates a transformation matrix between two given support. A support is defined by its topology and its node indices. For this function to work one of the given supports must be contained in the other one, i.e. they must paramterize the same space (line-to-line, quad-to-quad, etc.) or one must be a sub-support of the other (quad-to-line, hex-to-quad, hex-to-line, etc.).
Topology indices are defined as follows:
<ol>
<li> Line </li>
<li> Quad </li>
<li> Hex </li>
</ol>

<h3>moMakeFull.m</h3>
Elevates the given input vectors (provided as a matrix) to the given higher dimension. This is done by setting the new dimensions to a given default value.

<h3>moParseFunctionHandle.m</h3>
Function which extracts a function handle from a data structure and parses it to the output variable. It warns you, if the function handle is not defined in the data structure.

<h3>moParseScalar.m</h3>
Function which extracts a scalar value from a data structure and parses it to the output variable. It warns you, if the scalar value is not defined in the data structure.

<h3>moParseScalarWithoutWarning.m</h3>
Same as moParseScalar, but without a warning.

<h3>moPseudoDeterminant.m</h3>
A function returning the pseudo determinant for non-square matrices
$`\mathrm{det}\left(\mathbf{A}\right)^{*} = \sqrt{ \mathrm{det} \left( \mathbf{A}^\mathrm{T} \, \mathbf{A} \right)}`$
if $`\mathbf{A}`$ has more rows than columns and 
$`\mathrm{det}\left(\mathbf{A}\right)^{*} = \sqrt{ \mathrm{det} \left( \mathbf{A} \, \mathbf{A}^\mathrm{T} \right)}`$
if $`\mathbf{A}`$ has more columns than rows.


<h3>moPseudoInverse.m</h3>
A function returning the pseudo inverse for non-square matrices
$`\mathbf{A}^{*} = \left(\mathbf{A}^\mathrm{T} \, \mathbf{A} \right)^{-1} \, \mathbf{A}^\mathrm{T} `$
if $`\mathbf{A}`$ has more rows than columns and 
$`\mathbf{A}^{*} = \mathbf{A}^\mathrm{T} \, \left(\mathbf{A} \, \mathbf{A}^\mathrm{T} \right)^{-1}`$
if $`\mathbf{A}`$ has more columns than rows.


<h3>moSolveSparseSystem.m</h3>
A function taking a sparse system (matrix $`\mathbf{A}`$ and right hand side vector $`\mathbf{b}`$) and returnin the solution $`\mathbf{x}`$. Basically, 
<pre><code>
x = A \ b;
</code></pre>
can be used instead of this functions, however, warnings may appear if the matrix is badly conditioned.


<h2>Subdirectories in core/mathOperations/</h2>

<h3>specialMatrices/</h3>
Contains function to create special matrices like strain-displacement-matrices or interpolation matrices.

<h3>specialFunctions/</h3>
Contains MATLAB-functions to evaluate special mathematical functions like Lagrange polynomials, integrated Legendgre polynomials, etc.
