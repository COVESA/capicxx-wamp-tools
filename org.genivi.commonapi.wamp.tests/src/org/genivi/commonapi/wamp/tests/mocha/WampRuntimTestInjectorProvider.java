/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.mocha;

import org.franca.core.dsl.FrancaIDLInjectorProvider;

import com.google.inject.Injector;

public class WampRuntimTestInjectorProvider extends FrancaIDLInjectorProvider {
	
	@Override
	protected Injector internalCreateInjector() {
		return new WampRuntimeTestInfrastructureStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
