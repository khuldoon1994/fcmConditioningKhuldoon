<h1>Mesh creators</h1>

This subdirectory contains function to create or complete meshes.

<h2> Files in core/problemOperations/meshCreators/</h2>

<h3> README.md </h3>
This documentation page.

<h3> poCreateSubElements.m </h3>
For certain meshes, the subelements can be created automatically, provided that the elements are already defined. 
This functions takes the problem data structure, creates the subelements automatically if possible and returns an updated problem data structure.

<h3> poCreateElementConnections </h3>
The transformations between elements and subelements, stored in the field <b>elementConnections</b> of 
the problem data structure can always be created automatically using this function.
