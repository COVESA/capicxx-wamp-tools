package org.genivi.commonapi.wamp.generator

import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef

import static extension org.franca.core.framework.FrancaHelpers.*

class FrancaWampTypeExtensions {
	
	def String genType(FTypeRef typeRef) {
		if (typeRef.isInteger) {
			// all kinds of Franca integers are mapped to uint64_t
			"uint64_t"
		} else {
			if (typeRef.derived!=null) {
				typeRef.derived.genType
			} else {
				// non-integer basic types
				typeRef.predefined.genBasicType
			}
		}
	}
	
	def private String genBasicType(FBasicTypeId type) {
		throw new RuntimeException("WampGenerator: Basic type " + type.literal + " not supported yet.")
	}

	def private dispatch String genType(FStructType type) {
		type.name + "_internal"
	}

	def private dispatch String genType(FType type) {
		throw new RuntimeException("WampGenerator: Derived type " + type.class.name + " not supported yet.")
	}


}
