# capicxx-wamp-tools [![Build Status](https://travis-ci.org/GENIVI/capicxx-wamp-tools.svg?branch=master)](https://travis-ci.org/GENIVI/capicxx-wamp-tools)
Common API tooling with WAMP messaging.

## Runtime library

The binding code generator from this project will create C++ code which needs a proper runtime library.
One can find the runtime library in the companion project https://github.com/GENIVI/capicxx-wamp-runtime.
Please ensure that the runtime library version matches the code generator version.

## Command-line code generator

A jar-file with a portable command-line code generator from the latest successful master build can be downloaded
[from here](https://genivi.github.io/capicxx-wamp-tools/standalone/).

It can be started by running `java -jar org.genivi.commonapi.wamp.cli-0.7.0.v201804182032-standalone.jar`. Please update the actual filename according to the version you have downloaded. With additional arguments, it will dump a list of command line options. Here is a snapshot of this list.

```
Usage: java -jar org.genivi.commonapi.wamp.cli-0.7.0.v201804182032-standalone.jar [OPTIONS]
 -d,--dest <dir>                  Set output directory
 -dc,--dest-common <dir>          The directory for the common code
 -dp,--dest-proxy <dir>           The directory for proxy code
 -ds,--dest-stub <dir>            The directory for stub code
 -dsub,--dest-subdirs <dir>       Use subdir per interface
 -f,--fidl <Franca IDL file>      Input file in Franca IDL (fidl) format
 -h                               Print usage information
 -l,--license <filepath>          The file path to the license text that
                                  will be added to each generated file
 -ll,--loglevel <quiet|verbose>   The log level
 -nc,--no-common                  Switch off generation of common code
 -ng,--no-gen                     Switch off code generation
 -np,--no-proxy                   Switch off generation of proxy code
 -ns,--no-stub                    Switch off generation of stub code
 -nsc,--no-sync-calls             Switch off code generation
 -r,--recursive-validation        Recursive validation
 -v                               Activate verbose mode
```

## Code generator for JS client

There is an experimental JS code generator for the client-side, which can be used in combination with the 
CommonAPI C++ server-side generator.
It is provided as part of [Franca 13](https://github.com/franca/franca/releases/tag/v0.13.0) (or later).

This code generator supports so far:
- connect/disconnect handling
- methods (not including fireAndForget)
- broadcasts (not including selective)
- primitive types, plus arrays, enums and structs

There is now a context menu item `Generate JS code for Autobahn-binding` for fidl-files, available in the _Franca_ sub-menu. It will generate the client side proxy and a blueprint-example-file in the `src-gen` folder of the containing workspace project.

## Further information

Additional information on this project is available [in this presentation](https://projects.itemis.de/html/web-presentations/kbi/2017/2017_05_genivi_amm_francaweb/#/).
