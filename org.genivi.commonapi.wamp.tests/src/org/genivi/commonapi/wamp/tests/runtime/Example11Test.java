/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;

@MochaTest(//
		program = "mocha", //
		mochaReporterFile = "mochatest/reporter.js", //
		mochaTestFile = "mochatest/example11/Example11Test.js", //		
		model = "models/testcases/example11/ExampleInterface.fidl", //
		serviceName = "Example11Service"
)

public class Example11Test extends AbstractWampRuntimeTest {	
}
