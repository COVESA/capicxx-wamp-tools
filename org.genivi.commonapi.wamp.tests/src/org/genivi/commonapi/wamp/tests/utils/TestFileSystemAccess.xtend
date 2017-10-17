/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.utils

import org.eclipse.xtext.generator.InMemoryFileSystemAccess

class TestFileSystemAccess extends InMemoryFileSystemAccess {
	
	val private static SEP = "___"
	
	override String getFileName(String fileName, String outputConfigName) {
		outputConfigName + SEP + fileName
	}
	
	def static String extractFileName(String nameWithConfig) {
		val idx = nameWithConfig.indexOf(SEP)
		if (idx<0) {
			null
		} else {
			nameWithConfig.substring(idx + SEP.length)
		}
	}
	
}
