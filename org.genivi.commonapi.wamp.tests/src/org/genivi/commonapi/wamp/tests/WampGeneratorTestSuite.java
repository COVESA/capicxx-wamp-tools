package org.genivi.commonapi.wamp.tests;

import org.genivi.commonapi.wamp.tests.runtime.Example10Test;
import org.genivi.commonapi.wamp.tests.runtime.Example12Test;
import org.genivi.commonapi.wamp.tests.runtime.Example30Test;
import org.genivi.commonapi.wamp.tests.runtime.Example32Test;
import org.genivi.commonapi.wamp.tests.runtime.Example77Test;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({ //
		WampGeneratorTests.class, //
		Example10Test.class, //
		Example12Test.class, //
		Example30Test.class, //
		Example32Test.class, //
		Example77Test.class, //
})
public class WampGeneratorTestSuite {

}
