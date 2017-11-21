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

	String sourceFile();
	String program();
	String model();
	String reporterPath();
	String[] additionalFilesToCopy() default {};
	String[] additionalFilesToCompile() default {};

	/**
	 * If no test bundle provided, source test files (Mocha test) are expected to be
	 * in the Junit test's bundle.
	 * 
	 * If test bundle is provided, all test files are exepcted to be located in the
	 * test bundle. Also a project of the same name is created in Junit workspace.
	 * 
	 */
	String testBundle() default "";
	String modelBundle() default "";
}
