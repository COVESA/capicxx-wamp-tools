/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp;

import org.eclipse.xtext.util.Modules2;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * StandaloneSetup extension for the FrancaIDL DSL with the CommonAPI/WAMP C++ generator.
 *   
 * @author Klaus Birken (itemis AG)
 */
public class WampGeneratorFrancaStandaloneSetup extends FrancaIDLStandaloneSetup {

    @Override
    public Injector createInjector() {
        return Guice.createInjector(
        		Modules2.mixin(
        				new FrancaIDLRuntimeModule(),
        				new WampGeneratorModule()
        		));
    }
}
