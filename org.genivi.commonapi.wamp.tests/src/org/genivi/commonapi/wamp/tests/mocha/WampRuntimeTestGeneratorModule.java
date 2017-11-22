/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.mocha;

import org.eclipse.xtext.generator.IGenerator;
import org.genivi.commonapi.wamp.generator.FrancaWampGenerator;
import org.genivi.commonapi.core.generator.FrancaGenerator;

import com.google.inject.AbstractModule;
import com.google.inject.multibindings.Multibinder;

public class WampRuntimeTestGeneratorModule extends AbstractModule {

	@Override
	protected void configure() {
		Multibinder<IGenerator> generatorBinder = Multibinder.newSetBinder(
				binder(), IGenerator.class);
		generatorBinder.addBinding().to(FrancaGenerator.class);
		generatorBinder.addBinding().to(FrancaWampGenerator.class);
	}
}
