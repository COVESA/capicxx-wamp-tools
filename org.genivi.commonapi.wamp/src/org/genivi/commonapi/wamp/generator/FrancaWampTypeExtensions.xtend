package org.genivi.commonapi.wamp.generator

import com.google.inject.Inject
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FTypedElement
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions

import static extension org.franca.core.framework.FrancaHelpers.*

class FrancaWampTypeExtensions {
	@Inject private extension FrancaGeneratorExtensions

	val private ENUM_WIRE_TYPE = "uint32_t"
		
	def getTypenameOnWire(FTypedElement elem) {
		elem.getTypename(null, true, false)
	}

	def getTypenameOnWire(FTypedElement elem, FModelElement _container) {
		elem.getTypename(_container, true, false)
	}

	def getTypenameCode(FTypedElement elem) {
		elem.getTypename(null, false, false)
	}

	def getTypenameCode(FTypedElement elem, FModelElement _container) {
		elem.getTypename(_container, false, false)
	}

	def getTypenameInternal(FTypedElement elem, FModelElement _container) {
		elem.getTypename(_container, false, true)
	}

	// TODO: merge this with FrancaGeneratorExtensions.getElementType or .getTypeName
	def private getTypename(FTypedElement elem, FModelElement _container, boolean onWire, boolean internal) {
		val typeref = elem.type
		if (elem.isArray) {
			// TODO: check if this still works when the element type is a struct
			elem.getTypeName(_container, true)
		} else {
			if (typeref.isInteger || typeref.isBoolean || typeref.isString || typeref.isArray) {
				elem.getTypeName(_container, true)
			} else if (typeref.isStruct) {
				val n = typeref.actualDerived.name 
				if (internal) n + "_internal" else n
			} else if (typeref.isEnumeration) {
				if (onWire) {
					ENUM_WIRE_TYPE
				} else {
					elem.getTypeName(_container, true)
				}
			} else {
				// all other types are currently unsupported
				"UNSUPPORTED_DATATYPE"
			}
		}
	}

}
