/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;

@MochaTest(//
		program = "mocha", //
		mochaReporterFile = "mochatest/reporter.js", //
		mochaTestFile = "mochatest/example30/Example30Test.js", //		
		model = "models/testcases/example30/ExampleInterface.fidl", //
		serviceName = "Example30Service"
)

public class Example30Test extends AbstractWampRuntimeTest {	
}
