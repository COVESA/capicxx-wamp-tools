package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTest;
import org.genivi.commonapi.wamp.tests.mocha.MochaTestHelper;
import org.genivi.commonapi.wamp.tests.mocha.MochaTestRunner;
import org.junit.Before;
import org.junit.runner.RunWith;

@MochaTest(//
sourceFile = "mochatest/example77/Example77Test.js", //
program = "mocha",//
additionalFilesToCopy = { //
		"mochatest/reporter.js"//
		})
@RunWith(MochaTestRunner.class)
public class Example77Test {

	protected final MochaTestHelper helper = new MochaTestHelper(this);

	@Before
	public void setUp() {
		helper.copyFilesFromBundleToFolder();
		// helper.generate();
		// helper.compile();
	}
}
