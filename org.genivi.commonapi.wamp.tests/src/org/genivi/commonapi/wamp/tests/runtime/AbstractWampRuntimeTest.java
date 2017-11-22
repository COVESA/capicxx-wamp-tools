/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import org.genivi.commonapi.wamp.tests.mocha.MochaTestHelper;
import org.genivi.commonapi.wamp.tests.mocha.MochaTestRunner;
import org.genivi.commonapi.wamp.tests.mocha.WampRuntimTestInjectorProvider;
import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;

import com.google.inject.Injector;

/**
 * Abstract base class for a JUnit test wrapping a Mocha test.
 * 
 * @author muehlbrandt
 *
 */
@RunWith(MochaTestRunner.class)
public abstract class AbstractWampRuntimeTest {

	protected MochaTestHelper helper;

	protected WampRuntimTestInjectorProvider injectorProvider;

	public AbstractWampRuntimeTest() {
		injectorProvider = new WampRuntimTestInjectorProvider();
		helper = internalCreateTestHelper();
		getInjector().injectMembers(helper);
	}

	@Before
	public void setUp() {
		helper.generate();
		helper.compile();
		helper.startServer();
	}

	@After
	public void cleanUp() {
		destroy(helper.getCommonAPIServiceProcess());
		destroy(helper.getCrossbarIOProcess());
	}

	private void destroy(Process process) {
		if (process != null && process.isAlive()) {
			process.destroyForcibly();
		}
	}

	protected MochaTestHelper internalCreateTestHelper() {
		return new MochaTestHelper(this);
	}

	protected Injector getInjector() {
		return injectorProvider.getInjector();
	}
}
