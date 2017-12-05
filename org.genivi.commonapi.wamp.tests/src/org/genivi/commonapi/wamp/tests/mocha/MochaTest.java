/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.mocha;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Additional JUnit test annotation definitions to wrap a Mocha JavaScript test.
 * 
 * @author Markus Mühlbrandt
 *
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface MochaTest {

	String mochaTestFile();
	String mochaReporterFile();
	String program();
	String model();
	String serviceName();
	boolean generateSkeleton() default false;
}
