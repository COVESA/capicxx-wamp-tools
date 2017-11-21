package org.genivi.commonapi.wamp.tests.mocha;

import org.franca.core.dsl.FrancaIDLInjectorProvider;

import com.google.inject.Injector;

public class WampRuntimTestInjectorProvider extends FrancaIDLInjectorProvider {
	
	@Override
	protected Injector internalCreateInjector() {
		return new WampRuntimeTestInfrastructureStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
