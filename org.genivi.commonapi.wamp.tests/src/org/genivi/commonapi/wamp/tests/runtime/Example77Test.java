package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;
import org.genivi.commonapi.wamp.tests.mocha.MochaTestRunner;
import org.junit.Before;
import org.junit.runner.RunWith;

@MochaTest(//
sourceFile = "mochatest/example77/Example77Test.js", //
program = "mocha",//
model = "models/testcases/example77/ExampleInterface.fidl",//
reporterPath = "mochatest/reporter.js",//
additionalFilesToCopy = { //
"mochatest/reporter.js"//
})
@RunWith(MochaTestRunner.class)
public class Example77Test extends AbstractWampRuntimeTest {

	@Before
	public void setUp() {
		// helper.copyFilesFromBundleToFolder();
		helper.generate();
		// helper.compile();
	}
}
