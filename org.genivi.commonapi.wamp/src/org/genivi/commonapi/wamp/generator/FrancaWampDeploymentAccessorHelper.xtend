package org.genivi.commonapi.wamp.generator

import javax.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FMapType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.genivi.commonapi.wamp.deployment.PropertyAccessor

class FrancaWampDeploymentAccessorHelper {
    @Inject private extension FrancaWampGeneratorExtensions

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FTypedElement _element) {
        if (_accessor == null)
            return false
        if (_accessor.getWampIsObjectPathHelper(_element)) {
            return true
        }
        if (_accessor.getWampIsUnixFDHelper(_element)) {
            return true
        }        
        return _accessor.hasDeployment(_element.type)
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FArrayType _array) {
        if (_accessor.hasDeployment(_array.elementType)) {
            return true
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FEnumerationType _enum) {
        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FStructType _struct) {
        for (element : _struct.elements) {
            if (_accessor.hasDeployment(element)) {
                return true
            }
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FMapType _map) {
        return _accessor.hasDeployment(_map.valueType);
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FUnionType _union) {
        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FTypeDef _typeDef) {
        return _accessor.hasDeployment(_typeDef.actualType)
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FBasicTypeId _type) {
        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FType _type) {
        return false;
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FTypeRef _type) {
        if (_type.derived != null)
            return _accessor.hasDeployment(_type.derived)

        if (_type.predefined != null)
            return _accessor.hasDeployment(_type.predefined)

        return false
    }

    def boolean hasSpecificDeployment(PropertyAccessor _accessor,
                                      FTypedElement _attribute) {
        return false
    }

    def Boolean getWampIsObjectPathHelper(PropertyAccessor _accessor, EObject _obj) {
        return false;
    }
    def Boolean getWampIsUnixFDHelper(PropertyAccessor _accessor, EObject _obj) {
        return new Boolean(false);
    }
}
