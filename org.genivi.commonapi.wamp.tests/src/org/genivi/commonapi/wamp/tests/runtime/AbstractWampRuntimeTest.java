/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.runtime;

import java.util.logging.Logger;

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
 * @author Markus Mühlbrandt
 *
 */
@RunWith(MochaTestRunner.class)
public abstract class AbstractWampRuntimeTest {

	public static final String WAMP_RUNTIME_TEST_LOGGER = AbstractWampRuntimeTest.class.getName();

	protected static final Logger log = Logger.getLogger(WAMP_RUNTIME_TEST_LOGGER);

	protected MochaTestHelper helper;

	protected WampRuntimTestInjectorProvider injectorProvider;

	public AbstractWampRuntimeTest() {
		injectorProvider = new WampRuntimTestInjectorProvider();
		helper = internalCreateTestHelper();
		getInjector().injectMembers(helper);
	}

	@Before
	public void setUp() {
		log.info("Generating server code.");
		helper.generate();
		log.info("Compiling server code.");
		helper.compile();
		log.info("Start up servers.");
		helper.startServer();
	}

	@After
	public void cleanUp() {
		log.info("Shut down wamp server.");
		destroy(helper.getCommonAPIServiceProcess());
		log.info("Shut down CrossbarIO.");
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
