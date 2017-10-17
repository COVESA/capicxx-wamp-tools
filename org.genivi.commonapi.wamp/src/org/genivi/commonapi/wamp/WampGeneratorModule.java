/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp;

import org.eclipse.xtext.generator.IGenerator;
import org.genivi.commonapi.wamp.generator.FrancaWampGenerator;

import com.google.inject.AbstractModule;

/**
 * Guice configuration for C++ generator module.
 * 
 * @author Klaus Birken (itemis AG)
 */
public class WampGeneratorModule extends AbstractModule {

	@Override
	protected void configure() {
		bind(IGenerator.class).to(FrancaWampGenerator.class);
	}

}
