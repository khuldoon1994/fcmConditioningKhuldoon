# SiHoFemLab #

A **Si**mple **H**igh-**o**rder **F**inite **E**lement **M**ethod **Lab**oratory.

## What is it for? ##

*SiHoFemLab* should be the simplest *Matlab* finite element program that

* can carry out **linear static and dynamic structural mechanics** analyses
* supports element types of **different topology** in **one, two or three dimensions**
* supports **high-order elements**
* supports the **finite-cell method**
* allows for easy creation of new **element types** featuring new
  * topologies
  * ansatz spaces
  * quadrature rules
  * mappings
* allows for easy creation of new <b>top-level algorithms</b> such as
  * time integration schemes
  * mesh import/export
  * post processing routines


How simple can it be then? It is intendet to be used by students with a basic understanding of programming with the matlab language.
So only the basic concepts of procedural programming using matlab scripts and functions should be used to realize the above features.
This makes it possible to dive into the code in just one semester during the exercices and implement a new feature as a homework.

That is, from the programming point of view
* the code should not use complicated patterns from object-oriented programming
* clarity is much more important than efficiency
* new features should not affect the core code

## How does it work? ##

*SiHoFemLab* is a collection of *Matlab* files (**.m-files**).
Most of them contain one function each (filename = function name).


Most functions work with a central data object called **problem** from here on.
It is a **Matlab structure array**, a detailed description of what fields need to be provided can be found [here](core/problemOperations).
The problem can then be passed to the functions that make up *SiHoFemLab*.
It defines the entire analyses, including mesh data, boundary condition data, element types data and much more.


A typical procedure would be the following:

```matlab
%% create problem
problem.name = 'my Problem'
% define other fields of problem ...

%% perform analysis
[Ke, Fe, Le] = goCreateElementMatrices( problem );
[ K, F ] = goAssembleSystem( Ke, Fe, Le );
U = K \ F;
[ Ue ] = goDisassembleVector( U, Le );
% post process the results ...
```

Anyone, who is not confused by the above code snippet knows enough about finite elements and about programming with <i>Matlab</i>, that <b>from here on it should be learning by doing</b>.

## How do I get set up? ##
If you read this, you have probably already obtained a copy of the sources of *SiHoFemLab*.
If not, or if you are not sure whether you have the most recent version, you can download it [here](https://collaborating.tuhh.de/M-10/SiHoFemLab).

The first steps then could be

1. Start matlab and navigate to the top-level source directory containing this file and a matlab script **init.m**.
2. Run the script by typing ```matlab init``` in the **Matlab command line window**. This adds the subdirectories to the **Matlab path**, so that all functions of *SiHoFemLab* are accessable.
3. Run a script from the example subdirectory.

## Next steps ##
Every subdirectory with code has a page like this in which the purpose of all functions in that subdirectory is explained.

You can get an overview of the whole code in [core/](core/).
Then, after reading the page from [core/problemOperations/](core/problemOperations/), where the problem data structure is explained, a good entry points to the code is the function **createElementSystemMatrices**.
You can find its description in [core/elementOperations/](core/elementOperations/).

Since the code is - besides the problem data structure - purely functional, you can click through the functions in a tree-like manner in *Matlab*.
Simply right click on a function and choose the according task from the context menu.

## Files in the top level directory ##
### README.md ###
This documentation page.

### init.m ###
Adds all subdirectories of SiHoFemLab to the matlab path.

## Subdirectories in the top level directory ##

### core/ ###
The collection of functions that make up *SiHoFemLab*.
**The README.md from this subdirectory is a must-read!**

### examples/ ###
A collection of scripts containing exemplary analyses, ready to be run.
They all set up a problem and provide a good start into the work with *SiHoFemLab*.

### extensions/ ###
Functions which are specialized for a certain analysis.
This can be anything, from low level operations (shape functions, mappings, ...) up to high level operations (mesh readers, problem creators, ...).
If a new feature is to be implemented in *SiHoFemLab*, this is the directory where new files (and subdirectories) should go.

### sandbox/ ###
A place to play around. No warrenty is given for the correct functionality of any part of the code. But for this part, even less warranty is given...


### docs/ ##
Additional documentation pages, figures, etc.


# Shortcuts #
 * Markdown documentaion: [https://docs.gitlab.com/ee/user/markdown.html](https://docs.gitlab.com/ee/user/markdown.html)
 * Information for developers: [DEVELOPER.md](DEVELOPER.md)
 * Atom text editor with markdown preview: [https://atom.io/](https://atom.io/).
 * For a better markdown preview: After installation, open atom editor, packages menu, settings view, open, install. Then search for **markdown-preview-enhanced** and install.
