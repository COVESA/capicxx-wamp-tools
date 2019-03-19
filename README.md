# capicxx-wamp-tools [![Build Status](https://travis-ci.org/GENIVI/capicxx-wamp-tools.svg?branch=master)](https://travis-ci.org/GENIVI/capicxx-wamp-tools)
Common API tooling with WAMP messaging.

## Runtime library

The binding code generator from this project will create C++ code which needs a proper runtime library.
One can find the runtime library in the companion project https://github.com/GENIVI/capicxx-wamp-runtime.
Please ensure that the runtime library version matches the code generator version.

## Build Instructions for Linux/Windows

# Command line

You can build all code generators by calling maven from the command-line. Open a console and change in the directory org.genivi.commonapi.wamp.releng of your CommonAPI-Tools directory. Then call:

```bash
mvn -DCOREPATH=<path to your CommonAPI-Tools dir> -Dtarget.id=commonapi_wamp-oxygen clean verify
```
_COREPATH_ is the directory, that contains the target definition folder: `commonapi_wamp-oxygen`.

After the successful build you will find the command-line generators archived in `org.genivi.commonapi.wamp.cli.product/target/products/commonapi_wamp_generator.zip` and the update-sites in `org.genivi.commonapi.wamp.updatesite/target`.


```
Different command line options :
 -d,--dest <dir>                  Set output directory
 -dc,--dest-common <dir>          The directory for the common code
 -dp,--dest-proxy <dir>           The directory for proxy code
 -ds,--dest-stub <dir>            The directory for stub code
 -dsub,--dest-subdirs <dir>       Use subdir per interface
 -sp,--fidl <Franca IDL file>     Input file in Franca IDL (fidl) format
 -l,--license <filepath>          The file path to the license text that
                                  will be added to each generated file
 -ll,--loglevel <quiet|verbose>   The log level
 -nc,--no-common                  Switch off generation of common code
 -ng,--no-gen                     Switch off code generation
 -np,--no-proxy                   Switch off generation of proxy code
 -ns,--no-stub                    Switch off generation of stub code
 -nsc,--no-sync-calls             Switch off code generation of synchronous methods
 -nv,--no-val					  Switch off validation of the fidl file
 -pf,--printfiles				  Print out generated files
 -ve,--val-warnings-as-errors	  Treat validation warnings as errors
 -wod,--without-dependencies	  Switch off code generation of dependencies
```

# Eclipse

Make sure that you have installed the _m2e - Maven Integration for Eclipse_ plug-in. Then create a _Run Configuration_ in Eclipse. Open the _Run configuration_ settings. On the left side of you should find a launch configuration category _Maven Build_. Create a new launch configuration and add the parameters +target.id+ with the value +commonapi_wamp-oxygen+ and +COREPATH+ with the value +<path to your CommonAPI-Tools dir>+. Set the goals to clean verify.

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
