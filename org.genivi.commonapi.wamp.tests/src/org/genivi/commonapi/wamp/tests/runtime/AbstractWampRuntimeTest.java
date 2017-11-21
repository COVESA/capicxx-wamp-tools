package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTestHelper;
import org.genivi.commonapi.wamp.tests.mocha.WampRuntimTestInjectorProvider;

import com.google.inject.Injector;

public abstract class AbstractWampRuntimeTest {
	
	protected MochaTestHelper helper;
	
	protected WampRuntimTestInjectorProvider injectorProvider;
	
	public AbstractWampRuntimeTest() {
		injectorProvider = new WampRuntimTestInjectorProvider();
		helper = internalCreateTestHelper();
		getInjector().injectMembers(helper);
	}

	protected MochaTestHelper internalCreateTestHelper() {
		return new MochaTestHelper(this);
	}
	
	protected Injector getInjector() {
		return injectorProvider.getInjector();
	}
}
