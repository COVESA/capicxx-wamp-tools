package org.genivi.commonapi.wamp.generator

import com.google.inject.Inject
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FTypedElement
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions

import static extension org.franca.core.framework.FrancaHelpers.*

class FrancaWampTypeExtensions {
	@Inject private extension FrancaGeneratorExtensions

	def getTypename(FTypedElement elem) {
		elem.getTypeName(null, true)
	}

	def getTypename(FTypedElement elem, FModelElement _container) {
		elem.getTypeName(_container, true)
	}

}
