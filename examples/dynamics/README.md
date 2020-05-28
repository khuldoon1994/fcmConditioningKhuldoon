# Dynamic examples

Here you can find a step by step guide going through all the details of a dynamic simulation with SiHoFemLab.
It is recommended to look into the [first steps](/examples/firstSteps) before continuing with the dynamic examples.

## Files in examples/dynamics

### exDynamicBar1.m ###
Sets up a problem data structure for a simple one-dimensional problem and solves the problem with *Central Difference Method*.

### exDynamicBar2.m ###
Sets up a problem data structure for a simple one-dimensional problem and solves the problem with *Newmark Integration Method*.

### exDynamicPointMass.m ###
Sets up a point mass with initial velocity under gravitation.

### exDynamicQuad.m ###
Sets up a two dimensional plate unter tension and solves the elastodynamic problem.

### exDynamicQuad2.m ###
The two dimensional plate from exDynamicQuad, but with 2 elements.

### exDynamicTruss2d.m ###
Sets up a truss system which is loaded by a nodal force.
