/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests;

import org.franca.core.dsl.FrancaIDLInjectorProvider;
import org.genivi.commonapi.wamp.WampGeneratorFrancaStandaloneSetup;

import com.google.inject.Injector;

public class WampGenTestInjectorProvider extends FrancaIDLInjectorProvider {

	protected Injector internalCreateInjector() {
	    return new WampGeneratorFrancaStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
