# Problem Operations #

As mentioned in the top-level documentation page, almost all functions of *SiHoFemLab* work on a global data structure named **problem**.
It is a **Matlab structure array** (here's the official [online documentation](https://de.mathworks.com/help/matlab/ref/struct.html?searchHighlight=struct&s_tid=doc_srchtitle)) and provides the definition of the structural mechanics problem to be solved.
Every analysis performed with *SiHoFemLab* starts with defining the problem data structure.
<br>
This subdirectory contains functions that help you to set up the problem data structure.
However, before going through these functions, the most important fields of the problem data structure are explained.

##  Fields of the problem data structure ##
###  name  ###
You must always specify a name for your problem, i.e. put a line like this at the beginning of your analysis script:
```matlab
problem.name = 'your_funny_name';
```

###  dimension  ###
You must always specify the dimension of your problem, i.e.
```matlab
problem.dimension = 2;
```
for a two-dimensional problem.

###  elementTypes  ###
Element types are a central concept of *SiHoFemLab*. They must be specified for every analysis and define the type of finite elements to be used.
However, the element type does not define the shape functions to be used within an element, but everything else, such as the quadrature rule and the mapping.
Every element type is a field array itself, where most of the fields are function pointers.
Defining an element type manually would look like this:
```matlab
%% element type 1
myCoolElementType1.localDimension = 1;
myCoolElementType1.quadraturePointGetter = @gaussianQuadrature1d;
myCoolElementType1.quadraturePointGetterData = { 'gaussOrder', 2 };
myCoolElementType1.elementMatricesCreator = @standardElementMatricesCreator;
myCoolElementType1.elasticityMatrixGetter = @linearElasticityMatrix1d;
myCoolElementType1.elasticityMatrixGetterData = {'youngsModulus', 1.0e6, 'area', 1.0 };
myCoolElementType1.mappingEvaluator = @linearLineMapping1d;
myCoolElementType1.jacobianEvaluator = @linearLineJacobian1d;

%% element type 2
myCoolElementType2.localDimenation = 2;
% define the other fields...

%% add element types to problem data structure
problem.elementTypes = { myCoolElementType1, myCoolElementType2 };
```

While this concept allows you to combine different numerical methods in a flexible way, it is not a convenient way if just standard element types are needed.
So, there are functions in this subdirectory, which can create some standard element types for you.
For examble, the one dimensional line element type created above manually can also be added to the problem like this:
```matlab
myCoolElementType1 = poCreateElementType( 'STANDARD_LINE_1D', { 'gaussOrder', 2, 'youngsModulus', 1.0e6, 'area', 1.0 } );
```
A list of all predefined element types can be found <a href="core/problemOperations/elementTypeCreators">here</a>.

###  subelementTypes  ###
Subelement types work similar to element types. They specifiy the shape functions to be used by providing a function handle to function that evaluates shape functions as described <a href="core/subelementOperations/shapeFunctionEvaluators">here</a>.
This is how to define a subelement type manually:
```matlab
%% subelement type 1
myCoolSubelementType1.localDimension = 1;
myCoolSubelementType1.shapeFunctionEvaluater = @legendreLineShapeFunctions;
myCoolSubelementType1.shapeFunctionEvaluaterData = { 'order', 4 };
myCoolSubelementType1.numberOfNodalShapes = 0;
myCoolSubelementType1.numberOfInternalShapes = 5;

%% subelement type 2
myCoolSubelementType2.localDimenation = 2;
% define the other fields...

%% add subelement types to problem data structure
problem.elementTypes = { myCoolSubelementType1, myCoolSubelementType2 };
```

As for the element types, convenient functions are provided for standard types:
```matlab
%% subelement type 1
myCoolSubelementType1 = createSubelementType( 'LEGENDRE_LINE', { 'order', 2 } );
```

The concept of subelements is used in *SiHoFemLab* to ease the implementation of high-order finite elements.
A detailed description of the concept is given <a href="core/subelementOperations">here</a>.


### nodes ###
The nodes of the mesh used in the analysis. Of course, for large problems, this field will be read from a mesh file. However, for small problems it may be defined manually:
```matlab
problem.nodes = [ 0.0, 1.0, 0.0, 1.0;
                  0.0, 0.0, 1.0, 1.0 ];
```
As can be seen, the nodes field is a simple matrix containing one column for each node, i.e. $`\left[ \begin{array}{cccc} \mathbf{X}_1 & \mathbf{X}_2 & \ldots & \mathbf{X}_{n_\mathrm{nodes}} \end{array} \right]`$.

###  elementNodeIndicess  ###
A cell array with one entry for each element. Each entry is a matrix containing the indices of the element's nodes.

###  elementTopologyIndices  ###
A vector with one column for each element denoting its topology index. The index for a certain topology can be found <a href="core/mathOperations">here</a>.

###  elementTypeIndices  ###
A vector with one column for each element denoting its type index, i.e. the index of its type in the field elementTypes.


###  subelementNodeIndices  ###
Just like elementNodeIndices but for subelements.

###  subelementTopologyIndices  ###
Just like elementTopologyIndices but for subelements.

###  subelementTypeIndices  ###
Just like elementTypeIndices but for subelements.

**Subelements (the fields subelementNodeIndices, subelementTopologyIndices and subelementTypeIndices) may be created automatically using the function poCreateSubElements**.

###  elementConnections  ###
The connection information between elements and subelements.
As explained in detail [/core/subelementOperations/](/core/subelementOperations/), every element is connected to one or more subelements.
The connections are defined by a cell array with one entry for each element.
Each entry is a cell array itself with one entry for each subelement which is connected to that element.


Each of these entries, defining a conenction, is a cell array with two entries: The index of the subelement and a transformation matrix that maps coordinates from the element coordinate system to the subelement coordinate system.

The cell array of all element connections may look like this:
```matlab
problem.elementConnections = {
    { { 1 [ 1, 0; 0, 1] } },
    { { 1 [ 0, 1; 1, 0] } }
};
```

**The field elementConnections may be created automatically using the function poCreateElementConnections.**

###  loads  ###
The body loads and surface loads present in the problem under consideration. The field is a cell array with one entry for each load:
```matlab
loadFunction = @(X) cos(2*pi*X(1))+ sin(2*pi*X(2));
problem.loads = { [ 0.15; 0.0 ], loadFunction };
```
As can be seen, a load is either defined by a column vector with as many rows as there are dimensions in the problem or a function pointer, pointing to a function that returns such a column vector and expects as input arguments the global position.

###  elementLoads  ###
Defines the connections between elements and loads. The filed is a cell array with one entry for each element. Each entry is a column vector with as many columns as there are loads for this element. If no loads are present for an element, an emty matrix must be provided.
```matlab
problem.elementLoads = {
    [] [] [1]
};
```

###  penalties  ###
The penalty constraints present in the problem under consideration. The field is a cell array with one entry for each penalty constraint:
```matlab
problem.penalties = { [0, 1e60; 0, 1e60], [1, 1e60; 0, 0] };
```
As can be seen, a penalty constraint is defined by a matrix with two columns and as many rows as there are dimensions in the problem.
In the first column, the solution value is given. In the second column, the penalty value is given. This makes it possible to define penalty constraint that constrains only one coordinate of the solution by providing a penalty value of $`0`$ for the other dimension(s) as done above for the $`y`$-coordinate in the second penalty constraint.

###  elementPenalties  ###
Defines the connections between elements and penalty constraints. This field follows the same concept as the field elementLoads.
```matlab
problem.elementPenalties = {
    [1] [] []
};
```

**The best way to understand all the fields of the problem data structure is to look through the [examples](/core/examples).**


##  Files in core/problemOperations ##
###  content.txt  ###
This documentation page.

###  poCheckDynamicStabilityCDM.m  ###
Predicts for the _Central Difference Method_, if the dynamic analysis will be stable.
Therefore, it calculates both sampling time $`\Delta t`$ and the
critical sampling time $`\Delta t_{crit}`$. The analysis will be predicted as stable if $`\Delta t < \Delta t_{crit}`$.

###  poCheckProblem.m  ###
Contains the corresponding function which expects as the only input argument the problem data structure. It checks whether all necessary fields are provided and whether their values make sense.
**It is a good advise to alway call this function after setting up a problem!**

###  poConvertElementTypeToDynamic.m  ###
Converts an already existing standard element type to its dynamic version.

###  poCreateElementType.m  ###
Contains the corresponding function which creates an element type as explained above.

###  poCreateSubelementType.m  ###
Contains the corresponding function which creates a subelement type as explained above.

###  poInitializeDynamicProblem.m  ###
Checks if all fields reffering to the dynamic analysis are aviable and if their values are correct.
For not defined or incomplete fields standard variables will be defined.
Also the sampling time $`\Delta t`$ will be defined.


##  Subdirectories in core/problemOperations ##

###  elementTypeCreators/  ###
Contains functions that create a specific element type. These functions are called by the function **poCreateElementType**.

###  subelementTypeCreators/  ###
Contains functions that create a specific subelement type. These functions are called by the function **poCreateSubelementType**.

###  meshCreators/  ###
Contains functions that read in mesh files or create meshes directly. They return nodes, elements, subelements and connections between elements and subelements which can then be assigned to the respective fields of the problem data structure.

###  problemCreators/  ###
Contains functions that create an entire problem data structure according to some parameters. Typical structural mechanics problems which are used frequently when investigating new numerical methods (elastic bar, plate with hole, L-shaped domain) can thus be created in a fully automatic way.
