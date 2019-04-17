<h1>Sublement Operations</h1>

The concept of subelements is used in <b>SiHoFemLab</b> to separate the shape functions from the quadrature and mapping to be used within an element. Additionally, this eases the implementation of high-order elements in two or three dimensions, where special attention has to be paid to the orientation of edge and face modes between adjacent elements.

Therefore each element is made up of several subelements. While the element itself provides all information necessary for quadrature and mapping, the subelement contains the information necessary to evaluate the shape functions.
For example, a quad element is made up of one quad subelement, providing nodal and internal modes and four edge subelements, providing the edge modes. Now, if adjacent quad elements share the same subelement, the orientation issue mentioned above is fixed almost automatically.
All that needs to be done is to transform the coordinate, where the shape function is to be evaluated to the local coordinate system of the edge subelement. This coordinate system may coincide with that from one of the elements or be differently oriented. In any case, the corresponding transformation matrix can be computed automatically.
<br>
<br>
This document, although incomplete, may serve as a detailed explanation.
<br><br>
<center>
<iframe src="core/subelementOperations/pFemTransformations.pdf" style="width:750px; height:1000px;" frameborder="0"></iframe>
</center>
