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
		elem.getTypename(null, true)
	}

	def getTypenameOnWire(FTypedElement elem, FModelElement _container) {
		elem.getTypename(_container, true)
	}

	def getTypenameCode(FTypedElement elem) {
		elem.getTypename(null, false)
	}

	def getTypenameCode(FTypedElement elem, FModelElement _container) {
		elem.getTypename(_container, false)
	}

	// TODO: merge this with FrancaGeneratorExtensions.getTypeName
	def private getTypename(FTypedElement elem, FModelElement _container, boolean onWire) {
		val typeref = elem.type
		if (typeref.isEnumeration && onWire) {
			ENUM_WIRE_TYPE
		} else {
			elem.getTypeName(_container, true)
		}
	}

}
