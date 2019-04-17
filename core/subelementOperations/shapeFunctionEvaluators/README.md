<h1> Shape function evaluators </h1>

Shape function evaluators can be any function that takes a problem, a subelement index, the local coordinates in the subelement where the shape functions should be evaluated and the derivative (0,1,...).
This directory contains common shape functions.
According to the subelement concept as explained <a href="core/subelementOperations">here</a>, higher order shape functions are decomposed into nodal and internal modes living on one subelement and edge mode (in 2d) or face and edge modes (in 3d) that living on additional subelements. This is reflected in the shape function evaluators as follows:

<ul>
<li> In the one-dimensional case, the evaluators contain <b>Line</b>. They evaluate nodal and internal modes. Other subelement types are not needed. </li>
<li> In the two-dimensional case, the evaluators may contain <b>Quad</b>, <b>Triangle</b> or the name of any other two-dimensional topology. They evaluate nodal and internal modes. Additionally, there are evaluators that contain <b>Edge</b>. They evaluate the edge modes and do not have their own nodal modes.</li>
<li> In the three-dimensional case, the evaluators may contain <b>Hex</b>, <b>Tet</b> or the name of any other three-dimensional topology. They evaluate nodal and internal modes. Additionally, there are evaluators that contain <b>Face</b>. They evaluate the face modes and do not have their own nodal modes. Additionally, there are evaluators that contain <b>Edge</b>. They evaluate the edge modes and do not have their own nodal modes.</li>
</ul>


<h2> Files in core/subelementOperations/shapeFunctionEvaluators/</h2>

<h3>content.txt</h3>
This file.

<h3>linearLineShapeFunctions.m</h3>
The standard one-dimensional linear shape functions.

<h3>linearQuadShapeFunctions.m</h3>
The standard two-dimensional linear shape functions for quads.

<h3>legendreLineShapeFunctions.m</h3>
The one-dimensional hierarchic shape functions (integrated Legendre polynomials).

<h3>lagrangeLineShapeFunctions.m</h3>
The one-dimensional high-order nodal shape functions (Lagrange polynomials).

<h3>legendreQuadShapeFunctions.m</h3>
The two-dimensional hierarchic shape functions for quads (integrated Legendre polynomials, tensor porduct space).


<h3>legendreEdgeShapeFunctions.m</h3>
The two-dimensional high-order nodal shape functions for quads (Lagrange polynomials, tensor porduct space).
