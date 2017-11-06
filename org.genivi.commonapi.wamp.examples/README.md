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

1. generate code for fidl-files in models folder with CommonAPI-C++ Core generator (this will produce some C++ headers and sources in the src-gen directory)
2. generate code for fidl-files in models folder with CommonAPI-C++ Wamp generator (this will produce some more C++ headers and sources in the src-gen directory)
3. mkdir build
4. cd build
5. cmake ..
6. make


## How to run

### Preliminaries

- tested on Ubuntu 14.04
- Crossbar.io has to be installed

### Actual steps to run the service

1. build the executables and shared objects (see above)
2. cd workdir
3. start crossbar (depending on your installation directory, e.g., "/opt/crossbar/bin/crossbar start", will read .crossbar configuration)
3. open another shell: cd workdir/example77
4. start server with: ./runServer.sh

## Run the example HTML/JS client

In this example, Crossbar.io will pass the WAMP requests between client and server.

1. open browser
2. open file src/example77/client/index.html
3. enter two numbers and press "Compute sum"
4. a WAMP connection will be used to send the two arguments to the server and retrieve the results

Note: This example is currently based on the plain Autobahn/JS API. 
We probably will add a JS code generator lateron.

### Run the example REST client

In this example, Crossbar.io will map client-side REST requests to WAMP requests for the server
(and vice versa).

1. open shell and: cd workdir/example77
2. issue REST client request with ./runRESTClient.sh


#TODO: Add C++ client here.

 
