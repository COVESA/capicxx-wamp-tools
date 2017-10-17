/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.utils

/**
 * A utility for comparing generated C++ files with reference C++ files.
 * 
 * @author Klaus Birken (itemis AG)
 */
class CppFileComparer extends FileComparer {

	override boolean skipLine(String line) {
		if (super.skipLine(line)) {
			return true
		}
		
		if (line.matches("^\\s*//.*$")) {
			return true
		}
		
		return false
	} 
}
