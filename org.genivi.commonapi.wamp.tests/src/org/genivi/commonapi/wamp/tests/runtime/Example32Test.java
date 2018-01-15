/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;

@MochaTest(//
		program = "mocha", //
		mochaReporterFile = "mochatest/reporter.js", //
		mochaTestFile = "mochatest/example32/Example32Test.js", //
		model = "models/testcases/example32/ExampleInterface.fidl", //
		serviceName = "Example32Service", //
		generateSkeleton = true //
)

public class Example32Test extends AbstractWampRuntimeTest {
}
