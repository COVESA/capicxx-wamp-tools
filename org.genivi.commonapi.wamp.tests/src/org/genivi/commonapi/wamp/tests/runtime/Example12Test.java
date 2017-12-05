/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;

@MochaTest(//
		program = "mocha", //
		mochaReporterFile = "mochatest/reporter.js", //
		mochaTestFile = "mochatest/example12/Example12Test.js", //		
		model = "models/testcases/example12/ExampleInterface.fidl", //
		serviceName = "Example12Service"
)

public class Example12Test extends AbstractWampRuntimeTest {	
}
