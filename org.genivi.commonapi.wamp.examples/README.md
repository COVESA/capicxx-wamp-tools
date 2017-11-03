# C++ Examples for CommonAPI WAMP

This is a very coarse how-to. It should provide a bare minimum of information for brave early adopters.
It will be extended later, the example folder and build structure is subject to change.

## How to build

### Preliminaries

- tested on Ubuntu 14.04
- CommonAPI-C++ Core Runtime has to be installed
- CommonAPI-C++ Wamp Runtime has to be installed
- generators from CommonAPI-C++ Core Tools and Wamp Tools

### Actual build steps

* generate code for fidl-files in models folder with CommonAPI-C++ Core generator (this will produce some C++ headers and sources in the src-gen directory)
* generate code for fidl-files in models folder with CommonAPI-C++ Wamp generator (this will produce some more C++ headers and sources in the src-gen directory)
* mkdir build
* cd build
* cmake ..
* make


## How to run

### Preliminaries

- tested on Ubuntu 14.04
- Crossbar.io has to be installed

### Actual steps to run the service

* build the executables and shared objects (see above)
* cd workdir
* ./run.sh

