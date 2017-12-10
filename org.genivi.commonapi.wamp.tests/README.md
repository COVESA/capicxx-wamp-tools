# JUnit Runtime tests for CommonAPI WAMP

This is a very coarse how-to. It should provide a bare minimum of information for brave early adopters.
It will be extended later.

The JUnit test uses a custom runner to wrap a MochaJS JavaScript test which is used as test client.
During execution the test generates the Common API C++ Stubs and the Wamp support for a given Franca interface.
Afterwards it builds the server executable and executes Crossbar.io and the server. Finally the JUnit
test executes the MochaJS test and collects the test results to display them.

The JUnit test is configured via annotations only. The actual tests are implemented in JavaScript with the
MochaJS API. 

## How to run

### Preliminaries

- tested on Linux Mint 18.2 and 18.3. Linux Mint 18 is based on Ubuntu 16.04 LTS.
- CommonAPI-C++ Core Runtime has to be installed
- CommonAPI-C++ Wamp Runtime has to be installed
- generators from CommonAPI-C++ Core Tools and Wamp Tools
- [Crossbar.io](https://crossbar.io/)
- [AutobahnJS](https://github.com/crossbario/autobahn-js)
- [MochaJS](https://mochajs.org/)
- Python 2.7 (for Crossbar.io)

### Crossbar.io installation

- Phython should be already installed in a Ubuntu distribution
- Install the Python Package manager 'pip': `sudo apt-get install python-pip`
- Install Crossbar.io: `pip install crossbar`
  - Crossbar should be installed in the user home folder: **<usr_home>/.local/bin/crossbar**
    **The JUnit test actually expects the Crossbar installation in this folder.** If not
    add a symlink 'crossbar' to the folder which points to the crossbar executable.
- Additional help for [Installation on Linux](https://crossbar.io/docs/Installation-on-Linux/)
    
### MochaJS/AutobahnJS installation

- [MochaJS](https://mochajs.org/)
- Install NodeJS: `sudo apt-get install nodejs`
- Install Ubuntu package "npm" (NodeJS package manager): `sudo apt-get install npm`
- Install AutobahnJS: `sudo npm install --global autobahn`
- Install MochaJS: `sudo npm install --global mocha`
- Add environment variable: `export NODE_PATH=/usr/local/lib/node_modules/`

### Run the JUnit tests

You can execute the 'WampGeneratorTestSuite.java' test suite located in 'org.genivi.commonapi.wamp.tests'
package or each test separately (package 'org.genivi.commonapi.wamp.tests.runtime').
