/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests

import com.google.inject.Inject
import java.io.File
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaPersistenceManager
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertNotNull
import static org.junit.Assert.assertTrue
import org.genivi.commonapi.wamp.tests.utils.TestFileSystemAccess

//@SuppressWarnings("unused") 
@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(WampGenTestInjectorProvider))
public class WampGeneratorTests extends GeneratorTestBase {

	/** 
     * Generated code is written to files. This flag can be used, if the code generator
     * has changed and new test data has to be generated. In any case, it has to be ensured
     * that the newly generated code is correct. That is a manual step. 
     */
	val private static boolean OVERRIDE = false

	val private static String[] ignoredOutputFiles = #{ }

	val private static TEST_MODEL_FOLDER = "models/"
	val private static EXAMPLE_SUBFOLDER = "testcases"
	val private static REFCODE_FOLDER    = "src/refcode/"
	val private static VERSION_TAG = "v0"
	
	@Inject FrancaPersistenceManager loader
	@Inject IGenerator generator

	@Test
	def void test10() {
		doGeneratorTest(EXAMPLE_SUBFOLDER + SEP + "example10", "ExampleInterface"); //$NON-NLS-1$ 
	}

	@Test
	def void test12() {
		doGeneratorTest(EXAMPLE_SUBFOLDER + SEP + "example12", "ExampleInterface"); //$NON-NLS-1$ 
	}

	@Test
	def void test30() {
		doGeneratorTest(EXAMPLE_SUBFOLDER + SEP + "example30", "ExampleInterface"); //$NON-NLS-1$ 
	}

	@Test
	def void test77() {
		doGeneratorTest(EXAMPLE_SUBFOLDER + SEP + "example77", "ExampleInterface"); //$NON-NLS-1$ 
	}

	// helper method 
	def private void doGeneratorTest(String path, String fileBasename) {
		doGeneratorTest(path, fileBasename, SRC_GEN_DIR)
	}

	// helper method 
	def private void doGeneratorTest(
		String path,
		String fileBasename,
		String expectedSrcGenDir
	) { 
		// load example Franca IDL interface
		val inputfile = TEST_MODEL_FOLDER + path + SEP + fileBasename + ".fidl"
		System.out.println("Loading Franca file " + inputfile + " ...")
		val fmodel = loader.loadModel(inputfile)
		assertNotNull(fmodel)
		
		// prepare generator output
		val fsa = new TestFileSystemAccess
		fsa.setTextFileEnconding("UTF-8")
		
		// run generator
		//generator.init(new DefaultGeneratorConsole(), projectName, null); 
		generator.doGenerate(fmodel.eResource, fsa)

		// check if all reference files have been generated
		val expectedPath = VERSION_TAG + SEP + path
		val refFolderPath = REFCODE_FOLDER + SEP + expectedPath
		val refFolder = new File(refFolderPath)
		assertTrue("Missing folder for reference files '" + refFolderPath + "'", refFolder.exists())
		val refFiles = refFolder.listFiles 
		for(refFile : refFiles) {
			val expecting = refFile.name
			val foundGen = fsa.textFiles.keySet.findFirst[it.endsWith(expecting)]
			assertNotNull("Missing generated file for reference file '" + expecting + "'", foundGen)
		}

		// check output files against expected reference files
		for(key : fsa.textFiles.keySet) {
			// remove configuration from file name
			val outpathRaw = TestFileSystemAccess.extractFileName(key)
			assertNotNull(outpathRaw)
			val outpath = outpathRaw.replace("\\", "/")

			if (ignoredOutputFiles.findFirst[outpath.contains(it)] !== null) {
				// match in ignore list => ignore this file
				println("Ignoring generated file '" + outpath + "'")
			} else {
				//System.out.println("Checking generated file '" + outpath + "'") 
				val output = fsa.getTextFiles().get(key) 
				
				// check that outpath starts with correct path
				val expectedPathSep = expectedPath + SEP
				assertTrue(outpath.startsWith(expectedPathSep))
				
				val outfile = outpath.substring(expectedPathSep.length)
				val referenceFile = REFCODE_FOLDER + SEP + outpath
				if (OVERRIDE) { 
					overrideFile(referenceFile, output.toString) 
				}
				
				// read reference file and compare with generated file
				val expected = readFile(referenceFile)
				assertNotNull("Cannot read reference file '" + referenceFile + "'", expected)
				val ok = isEqual(expected, output.toString)
				if (!ok) {
					System.out.println(output)
				}				
				assertTrue("Generated file '" + outpath + "' does not match reference file '" + referenceFile + "'", ok)				
			}
		}
	} 

//        def private void doGeneratorTestAndSearchOutput(String testcase, boolean generateReturn, String... expected) { 
//                final ByteArrayOutputStream output = new ByteArrayOutputStream(); 
//                PrintStream out = System.out; 
//                System.setOut(new PrintStream(output)); 
//                doGeneratorTest(testcase, generateReturn, null); //$NON-NLS-1$ 
//                System.setOut(out); 
//                for (String e : expected) { 
//                        assertTrue(output.toString().contains(e)); 
//                } 
//        } 

}
