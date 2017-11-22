/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;

@MochaTest(//
		program = "mocha", //
		mochaReporterFile = "mochatest/reporter.js", //
		mochaTestFile = "mochatest/example77/Example77Test.js", //		
		model = "models/testcases/example77/ExampleInterface.fidl", //
		serviceName = "Example77Service"
)

public class Example77Test extends AbstractWampRuntimeTest {	
}
