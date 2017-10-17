/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.utils

/**
 * A configurable utility for comparing generated files with reference files.
 * This is less detailed than EMF Compare and more convenient than a plain string compare.
 * 
 * @author Klaus Birken (itemis AG)
 */
class FileComparer {

	val static final LINE_SEPARATOR = System.getProperty("line.separator")

	public static class Conflict {
		val public int lineExpected
		val public int lineActual
		val public String expected
		val public String actual
		
		new(int le, int la, String se, String sa) {
			lineExpected = le+1
			lineActual = la+1
			expected = se
			actual = sa
		}
	}

	def Conflict checkEqual(String expected, String actual) {
		val String[] expectedLines = expected.split(LINE_SEPARATOR)
		val String[] actualLines = actual.split(LINE_SEPARATOR)
		
		var ie = 0
		var ia = 0
		while (ie<expectedLines.length && ia<actualLines.length) {
			ie = proceed(expectedLines, ie)
			ia = proceed(actualLines, ia)
			
			if (ie<expectedLines.length && ia<actualLines.length) {
				val le = prepare(expectedLines.get(ie))
				val la = prepare(actualLines.get(ia))
				if (! le.equals(la))
					return new Conflict(ie, ia, le, la)
				ie++
				ia++
			}
		}
		
		// eat trailing empty lines
		if (ie<expectedLines.length) {
			ie = proceed(expectedLines, ie)
		}
		if (ia<actualLines.length) {
			ia = proceed(actualLines, ia)
		}

		// check remaining lines in one of the files
		if (ie<expectedLines.length) {
			return new Conflict(ie, -1, expectedLines.get(ie), null)
		}
		if (ia<actualLines.length) {
			return new Conflict(-1, ia, null, actualLines.get(ia))
		}
		return null
	}

	def private int proceed(String[] text, int idx) {
		var i = idx
		var j = i
		do {
			j = i
			
			// skip over empty lines
			while (i<text.length && skipLine(text.get(i))) {
				i++
			}
	
			// skip over comments etc.
			if (i<text.length && skipRegionStart(text.get(i))) {
				do {
					i++
				} while (i<text.length && !skipRegionEnd(text.get(i)))
				if (i<text.length)
					i++
			}
		} while (i<text.length && j<i)
		
		return i
	}

	def protected String prepare(String line) {
		line.replaceAll("\\t", "    ")
	}

	def protected boolean skipLine(String line) {
		// ignore empty lines
		line.matches("^\\s*$")
	}

	def protected boolean skipRegionStart(String line) {
		false
	}

	def protected boolean skipRegionEnd(String line) {
		false
	}
	
}
