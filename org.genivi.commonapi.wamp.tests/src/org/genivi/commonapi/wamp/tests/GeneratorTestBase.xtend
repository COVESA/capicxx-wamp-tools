/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests

import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.FileInputStream
import java.io.FileWriter
import java.io.IOException
import java.io.InputStreamReader
import org.eclipse.core.runtime.Path
import org.genivi.commonapi.wamp.tests.utils.CppFileComparer
import org.genivi.commonapi.wamp.tests.utils.FileComparer

class GeneratorTestBase {

	val protected static String SRC_GEN_DIR = "src-gen"
	val protected static final String SEP = "/"

	def protected String readFile(String filename) {
		val contents = new StringBuilder
		val path = new Path(filename)
		val file = path.toFile

		if (! file.exists) {
			logError("Input file '" + filename + "' does not exist")
			return null
		}

		try {
			// FileReader reads using default encoding
			val reader = new InputStreamReader(new FileInputStream(path.toFile))
			var input = new BufferedReader(reader)
			try {
				var String line = null
				do {
					line = input.readLine
					if (line !== null) {
						contents.append(line)
						contents.append(System.getProperty("line.separator"))
					}
				} while (line !== null)
			} finally {
				input.close
			}
		} catch (IOException ex) {
			ex.printStackTrace
		}

		return contents.toString();
	}

	def protected void overrideFile(String filename, String content) {
		try {
			val writer = new BufferedWriter(new FileWriter(filename))
			try {
				writer.write(content)
			} finally {
				writer.close
			}
		} catch (IOException e) {
			e.printStackTrace
		}
	}

	def protected boolean isEqual(String expected, String actual) {
		val FileComparer fc = new CppFileComparer
		isEqualAux(expected, actual, fc)
	}

	def private boolean isEqualAux(String expected, String actual, FileComparer fc) {
		val conflict = fc.checkEqual(expected, actual)
		if (conflict !== null) {
			System.out.println("Files differ:")
			if (conflict.lineExpected != 0)
				System.out.println("  expected (line " + conflict.lineExpected + "): /" + conflict.expected + "/")
			else
				System.out.println("  expected: EOF")

			if (conflict.lineActual != 0)
				System.out.println("  actual (line " + conflict.lineActual + "):   /" + conflict.actual + "/")
			else
				System.out.println("  actual: EOF")
			false
		} else {
			true
		}
	}

	def protected logError(String msg) {
		System.err.println("GeneratorTest: " + msg)
	}
}
