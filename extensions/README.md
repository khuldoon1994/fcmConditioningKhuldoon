
# Extensions #
In this subdirectory, code for extensions is stored. Extensions can be used to **implement new features without changing the core**. Due to the concept of element types and subelement type, expained in detail in [core/problemOperations](core/problemOperations), it is possible to create completely new numerical methods just by providing a suitable extension.

## How to create a new extension ##
To create a new extension, simply follow these steps:

* Create a subdirectory with the name of your extension.
* In the new subdirectory, put a file named **README.md**, where your extension can be documented.
* Add your extension directory to the *Matlab path* as done in the top-level file **init.m**.
* Start adding matlab files to your subdirectory. Document as you program!

If you want to add subdirectories inside your newly created subdirectory, repeat the steps accordingly.
