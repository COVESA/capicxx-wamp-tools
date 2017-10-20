package org.genivi.commonapi.wamp.generator

import java.util.Collection
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set
import javax.inject.Inject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp
import org.osgi.framework.FrameworkUtil
import org.osgi.framework.Version

import static com.google.common.base.Preconditions.*

class FrancaWampGeneratorExtensions {
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaWampDeploymentAccessorHelper

    def String wampDeploymentHeaderFile(FInterface fInterface) {
        return fInterface.elementName + "WampDeployment.hpp"
    }

    def String wampDeploymentSourceFile(FInterface fInterface) {
        return fInterface.elementName + "WampDeployment.cpp"
    }

    def String wampDeploymentHeaderPath(FInterface fInterface) {
        return fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampDeploymentHeaderFile
    }

    def String wampDeploymentSourcePath(FInterface fInterface) {
        return fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampDeploymentSourceFile
    }

    def generateWampBaseInstantiations(FInterface _interface) {
        val List<FInterface> baseInterfaces = getBaseInterfaces(_interface)
        return baseInterfaces.map[getTypeCollectionName(_interface) + "WampProxy(_address, _connection)"].join(',\n')
    }

    def wampInSignature(FMethod fMethod, PropertyAccessor deploymentAccessor) {
        fMethod.inArgs.map[getTypeWampSignature(deploymentAccessor)].join;
    }

    def wampOutSignature(FMethod fMethod, PropertyAccessor deploymentAccessor) {
        var signature = fMethod.outArgs.map[getTypeWampSignature(deploymentAccessor)].join;

        if (fMethod.hasError)
            signature = fMethod.wampErrorSignature(deploymentAccessor) + signature

        return signature
    }

    def wampErrorSignature(FMethod fMethod, PropertyAccessor deploymentAccessor) {
        checkArgument(fMethod.hasError, 'FMethod has no error: ' + fMethod)

        if (fMethod.errorEnum != null)
            return fMethod.errorEnum.wampFTypeSignature(deploymentAccessor)

        return fMethod.errors.wampFTypeSignature(deploymentAccessor)
    }
    
    def wampErrorReplyOutSignature(FBroadcast fBroadcast, FMethod fMethod, PropertyAccessor deploymentAccessor) {
        checkArgument(fBroadcast.isErrorType(deploymentAccessor), 'FBroadcast is no valid error type: ' + fBroadcast)

        var signature = "s";
        if(!fBroadcast.errorArgs(deploymentAccessor).empty) {
            signature = fBroadcast.errorArgs(deploymentAccessor).map[getTypeWampSignature(deploymentAccessor)].join;
        }
        return signature
    }

    def wampSetMethodName(FAttribute fAttribute) {
        'set' + fAttribute.className
    }

    def wampGetMethodName(FAttribute fAttribute) {
        'get' + fAttribute.className
    }

    def wampSignalName(FAttribute fAttribute) {
        'on' + fAttribute.className + 'Changed'
    }

    def String wampSignature(FAttribute fAttribute, PropertyAccessor deploymentAccessor) {
        fAttribute.getTypeWampSignature(deploymentAccessor)
    }

    def String wampSignature(FBroadcast fBroadcast, PropertyAccessor deploymentAccessor) {
        fBroadcast.outArgs.map[getTypeWampSignature(deploymentAccessor)].join
    }

    def getTypeWampSignature(FTypedElement element, PropertyAccessor deploymentAccessor) {
        if (element.array) {
            return "a" + element.typeWampSignature(deploymentAccessor)
        } else {
            return element.typeWampSignature(deploymentAccessor)
        }
    }

    def String typeWampSignature(FTypedElement element, PropertyAccessor deploymentAccessor) {
        var FTypeRef fTypeRef = element.type
        if (fTypeRef == null)
            return "";
        // test for getIsObjectPath
        var Boolean test = deploymentAccessor.getWampIsObjectPathHelper(element);
        if (test != null && test)
            return "o"
        // test for getIsUnixFD
        var Boolean testFD = deploymentAccessor.getWampIsUnixFDHelper(element);
        if (testFD != null && testFD)
            return "h"

        if (fTypeRef.derived != null)
            return fTypeRef.derived.wampFTypeSignature(deploymentAccessor)
        return fTypeRef.predefined.wampSignature
    }

    def String wampSignature(FTypeRef fTypeRef, PropertyAccessor deploymentAccessor) {
        if (fTypeRef == null)
            return "";

        if (fTypeRef.derived != null)
            return fTypeRef.derived.wampFTypeSignature(deploymentAccessor)
        return fTypeRef.predefined.wampSignature
    }

    def private dispatch wampFTypeSignature(FTypeDef fTypeDef, PropertyAccessor deploymentAccessor) {
        return fTypeDef.actualType.wampSignature(deploymentAccessor)
    }

    def private dispatch wampFTypeSignature(FArrayType fArrayType, PropertyAccessor deploymentAccessor) {
        return 'a' + fArrayType.elementType.wampSignature(deploymentAccessor)
    }

    def private dispatch wampFTypeSignature(FMapType fMap, PropertyAccessor deploymentAccessor) {
        return 'a{' + fMap.keyType.wampSignature(deploymentAccessor) + fMap.valueType.wampSignature(deploymentAccessor) + '}'
    }

    def private dispatch wampFTypeSignature(FStructType fStructType, PropertyAccessor deploymentAccessor) {
        if (fStructType.isPolymorphic)
            return '(uv)'
        return '(' + fStructType.getElementsWampSignature(deploymentAccessor) + ')'
    }

    def private dispatch wampFTypeSignature(FEnumerationType fEnumerationType, PropertyAccessor deploymentAccessor) {
        val FBasicTypeId backingType = fEnumerationType.getBackingType(deploymentAccessor)
        
        if (backingType == FBasicTypeId.UNDEFINED)
            return FBasicTypeId.INT32.wampSignature

        return backingType.wampSignature
    }

    def private dispatch wampFTypeSignature(FUnionType fUnionType, PropertyAccessor deploymentAccessor) {
        return '(yv)'
    }

    def private String getElementsWampSignature(FStructType fStructType, PropertyAccessor deploymentAccessor) {
        var signature = fStructType.elements.map[getTypeWampSignature(deploymentAccessor)].join

        if (fStructType.base != null) {
            signature = fStructType.base.getElementsWampSignature(deploymentAccessor) + signature
        }

        return signature
    }

    def private wampSignature(FBasicTypeId fBasicTypeId) {
        switch fBasicTypeId {
            case FBasicTypeId::BOOLEAN: 'b'
            case FBasicTypeId::INT8: 'y'
            case FBasicTypeId::UINT8: 'y'
            case FBasicTypeId::INT16: 'n'
            case FBasicTypeId::UINT16: 'q'
            case FBasicTypeId::INT32: 'i'
            case FBasicTypeId::UINT32: 'u'
            case FBasicTypeId::INT64: 'x'
            case FBasicTypeId::UINT64: 't'
            case FBasicTypeId::FLOAT: 'd'
            case FBasicTypeId::DOUBLE: 'd'
            case FBasicTypeId::STRING: 's'
            case FBasicTypeId::BYTE_BUFFER: 'ay'
            default: throw new IllegalArgumentException("Unsupported basic type: " + fBasicTypeId.getName)
        }
    }

    def Version getWampVersion() {
        val bundle = FrameworkUtil::getBundle(this.getClass())
        if (bundle===null) {
        	// no bundle, cannot determine version
        	null
        } else {
	        val bundleContext = bundle.getBundleContext();
	        for (b : bundleContext.bundles) {
	            if (b.symbolicName.equals("org.genivi.commonapi.wamp")) {
	                return b.version
	            }
	        }
        }
    }

    def generateCommonApiWampLicenseHeader() {
    	val bundleVersion = getWampVersion
	    '''
	        /*
	        * This file was generated by the CommonAPI Generators.
	        * Used org.genivi.commonapi.wamp «IF bundleVersion!==null»«bundleVersion»«ELSE»(standalone)«ENDIF».
	        * Used org.franca.core «FrancaGeneratorExtensions::getFrancaVersion()».
	        *
	        «getCommentedString(getWampLicenseHeader())»
	        */
	    '''
	}
	
    def getWampLicenseHeader() {
        return FPreferencesWamp::instance.getPreference(PreferenceConstantsWamp::P_LICENSE_WAMP, PreferenceConstantsWamp.DEFAULT_LICENSE)
    }


    def boolean isVariant(FAttribute _attribute) {
        return _attribute.type.isVariantType()
    }

    def private dispatch boolean isVariantType(FTypeRef _typeRef) {
        if (_typeRef.derived != null)
            return _typeRef.derived.isVariantType()

        return false
    }

    def private dispatch boolean isVariantType(FTypeDef _typeDef) {
        return isVariantType(_typeDef.actualType)
    }

    def private dispatch boolean isVariantType(FType _type) {
        return (_type instanceof FUnionType)
    }

    def addRequiredHeaders(FType fType, Collection<String> generatedHeaders) {
        generatedHeaders.add(fType.FTypeCollection.wampDeploymentHeaderPath)
    }
    private static Map<FTypeCollection, PropertyAccessor> accessors__ = new HashMap<FTypeCollection, PropertyAccessor>()

    def insertAccessor(FTypeCollection _tc, PropertyAccessor _pa) {
        accessors__.put(_tc, _pa)
    }

    def FTypeCollection findTypeCollection(EObject fType) {
        if (fType.eContainer == null)
            return null
        if (fType.eContainer instanceof FTypeCollection)
            return fType.eContainer as FTypeCollection
        return findTypeCollection(fType.eContainer)
    }

    def PropertyAccessor getAccessor(FTypeCollection _tc) {
        return accessors__.get(_tc)
    }
    def getFTypeCollection(FType fType) {
        fType.eContainer as FTypeCollection
    }
    def String wampDeploymentHeaderPath(FTypeCollection _tc) {
        return _tc.versionPathPrefix + _tc.model.directoryPath + '/' + _tc.wampDeploymentHeaderFile
    }
    def String wampDeploymentHeaderFile(FTypeCollection _tc) {
        return _tc.elementName + "WampDeployment.hpp"
    }
    def String wampDeploymentSourcePath(FTypeCollection _tc) {
        return _tc.versionPathPrefix + _tc.model.directoryPath + '/' + _tc.wampDeploymentSourceFile
    }
     def String wampDeploymentSourceFile(FTypeCollection _tc) {
        return _tc.elementName + "WampDeployment.cpp"
    }
    ////////////////////////////////////////
    // Get deployment type for an element //
    ////////////////////////////////////////
    def dispatch String getDeploymentType(FTypeDef _typeDef, FInterface _interface, boolean _useTc) {
        return _typeDef.actualType.getDeploymentType(_interface, _useTc)
    }

    def dispatch String getDeploymentType(FTypedElement _typedElement, FInterface _interface, boolean _useTc) {
        if (_typedElement.array)
            return "CommonAPI::Wamp::ArrayDeployment< " + _typedElement.type.getDeploymentType(_interface, _useTc) + " >"
        return _typedElement.type.getDeploymentType(_interface, _useTc)
    }

    def dispatch String getDeploymentType(FTypeRef _typeRef, FInterface _interface, boolean _useTc) {
        if (_typeRef.derived != null)
            return _typeRef.derived.getDeploymentType(_interface, _useTc)

        if (_typeRef.predefined != null)
            return _typeRef.predefined.getDeploymentType(_interface, _useTc)

        return "CommonAPI::EmptyDeployment"
    }

    def dispatch String getDeploymentType(FBasicTypeId _type, FInterface _interface, boolean _useTc) {
        if (_type == FBasicTypeId.STRING)
            return "CommonAPI::Wamp::StringDeployment"
        if (_type == FBasicTypeId.UINT32)
            return "CommonAPI::Wamp::IntegerDeployment" 
        if (_type == FBasicTypeId.INT32)
            return "CommonAPI::Wamp::IntegerDeployment" 
       return "CommonAPI::EmptyDeployment"
    }

    def dispatch String getDeploymentType(FEnumerationType _enum, FInterface _interface, boolean _useTc) {
        return "CommonAPI::EmptyDeployment"
    }

    def dispatch String getDeploymentType(FType _type, FInterface _interface, boolean _useTc) {
        var String deploymentType = ""

        if (_useTc) {
            if (_type.eContainer instanceof FTypeCollection && !(_type.eContainer instanceof FInterface)) {
                deploymentType += (_type.eContainer as FModelElement).getFullName + "_::"
            }
            else if (_interface != null) {
                deploymentType += _interface.getFullName + "_::"
            }
        }
        else if (_interface != null) {
            deploymentType += _interface.getFullName + "_::"
        }

        deploymentType += _type.name + "Deployment_t"
    }

    ////////////////////////////////////////
    // Get deployment type for an element //
    ////////////////////////////////////////
    def String getDeploymentName(FTypedElement _typedElement, FModelElement _element, FInterface _interface, PropertyAccessor _accessor) {
        if (_accessor.hasSpecificDeployment(_typedElement) ||
            _typedElement.array && _accessor.hasDeployment(_typedElement)) {
            var String deployment = ""
            if (_element != null) {
                val container = _element.eContainer()
                if (container instanceof FTypeCollection) {
                    deployment += container.getFullName + "_::"
                }
                if (!(_element instanceof FTypedElement && _element == _typedElement))
                    deployment += _element.name + "_"
            } else {
                val container = _typedElement.eContainer()
                if (container instanceof FTypeCollection) {
                    deployment += container.getFullName + "_::"
                }
            }
            deployment += _typedElement.name + "Deployment"
            return deployment
        } else {
            return _typedElement.type.getDeploymentName(_interface, _accessor)
        }
    }

    def dispatch String getDeploymentName(FTypeDef _typeDef, FInterface _interface, PropertyAccessor _accessor) {
        return _typeDef.actualType.getDeploymentName(_interface, _accessor)
    }

    def dispatch String getDeploymentName(FTypeRef _typeRef, FInterface _interface, PropertyAccessor _accessor) {
        if (_typeRef.derived != null) {
            return _typeRef.derived.getDeploymentName(_interface, _accessor)
        }
        return _typeRef.predefined.getDeploymentName(_interface, _accessor)
    }

    def dispatch String getDeploymentName(FType _type, FInterface _interface, PropertyAccessor _accessor) {
        if (_accessor.hasDeployment(_type)) {
            var String name = ""
            val EObject container = _type.eContainer()
            if (container instanceof FTypeCollection) {
                name += container.getFullName + "_::"
            }
            name += _type.name + "Deployment"
            return name
        }
        return ""
    }

    def dispatch String getDeploymentName(FBasicTypeId _typeId, FInterface _interface, PropertyAccessor _accessor) {
        return ""
    }

    ///////////////////////////////////////////////////////////
    // Get reference (C++ pointer) to a deployment parameter //
    ///////////////////////////////////////////////////////////
    def String getDeploymentRef(FTypedElement _typedElement, boolean _isArray, FModelElement _element, FInterface _interface, PropertyAccessor _accessor) {
        val String name = _typedElement.getDeploymentName(_element, _interface, _accessor)
        if (name != "")
            return "&" + name

        var String deployment = "static_cast< "
        deployment += _typedElement.getDeploymentType(_interface, true)
        deployment += "* >(nullptr)"
        return deployment
    }

    def String getDeploymentRef(FTypeRef _typeRef, FInterface _interface, PropertyAccessor _accessor) {
        val String name = _typeRef.getDeploymentName(_interface, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _typeRef.getDeploymentType(_interface, true) + "* >(nullptr)"
    }

    def String getDeploymentRef(FType _type, FInterface _interface, PropertyAccessor _accessor) {
        val String name = _type.getDeploymentName(_interface, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _type.getDeploymentType(_interface, true) + "* >(nullptr)"
    }

    def String getDeploymentRef(FBasicTypeId _typeId, FInterface _interface, PropertyAccessor _accessor) {
        val String name = _typeId.getDeploymentName(_interface, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _typeId.getDeploymentType(_interface, true) + "* >(nullptr)"
    }

    def String getErrorDeploymentRef(FMethod _method, FInterface _interface, PropertyAccessor _accessor) {
        var String name = ""
        if ( _method.errorEnum != null) {
            name += _method.errorEnum.getDeploymentName(_interface, _accessor)
            if (name != "")
                return "&" + name
        }
        return "static_cast< " + _method.getErrorDeploymentType(false) + " * >(nullptr)"
    }

    ////////////////////
    // Get deployable //
    ////////////////////
    def String getDeployable(FArgument _argument, FInterface _interface, PropertyAccessor _accessor) {
        return "CommonAPI::Deployable< " + _argument.getTypeName(_interface, true) + ", " + _argument.getDeploymentType(_interface, true) + " >"
    }

    def String getDeployables(EList<FArgument> _arguments, FInterface _interface, PropertyAccessor _accessor) {
        return _arguments.map[getDeployable(_interface, _accessor)].join(", ")
    }

    def String getDeploymentTypes(EList<FArgument> _arguments, FInterface _interface, PropertyAccessor _accessor) {
        return _arguments.map[getDeploymentType(_interface, true)].join(", ")
    }

    def boolean hasDeployedArgument(FBroadcast _broadcast, PropertyAccessor _accessor) {
        for (a : _broadcast.outArgs) {
            if (_accessor.hasDeployment(a)) {
                return true
            }
        }
        return false
    }

    def String getDeployments(FBroadcast _broadcast,
                              FInterface _interface,
                              PropertyAccessor _accessor) {
        return "std::make_tuple(" + _broadcast.outArgs.map[getDeploymentRef(it.array, _broadcast, _interface, _accessor)].join(", ")  + ")"
   }

    def boolean hasDeployedArgument(FMethod _method, PropertyAccessor _accessor,
                                             boolean _in, boolean _out) {
        if (_in) {
            for (a : _method.inArgs) {
                if (_accessor.hasDeployment(a)) {
                    return true
                }
            }
        }

        if (_out) {
            for (a : _method.outArgs) {
                if (_accessor.hasDeployment(a)) {
                    return true
                }
            }
        }

        return false
    }

    def String getDeployments(FMethod _method,
                              FInterface _interface,
                              PropertyAccessor _accessor,
                              boolean _withInArgs, boolean _withOutArgs) {
        var String inArgsDeployments = ""
        if (_withInArgs) {
            inArgsDeployments = _method.inArgs.map[getDeploymentRef(it.array, _method, _interface, _accessor)].join(", ")
        }

        var String outArgsDeployments = ""
        if (_withOutArgs) {
            outArgsDeployments = _method.outArgs.map[getDeploymentRef(it.array, _method, _interface, _accessor)].join(", ")
            if (_method.hasError) {
                var String errorDeployment = _method.getErrorDeploymentRef(_interface, _accessor)
                if (outArgsDeployments != "")
                    outArgsDeployments = errorDeployment + ", " + outArgsDeployments
                else
                    outArgsDeployments = errorDeployment
            }
        }

        var String deployments = inArgsDeployments
        if (outArgsDeployments != "") {
            if (deployments != "") deployments += ", "
            deployments += outArgsDeployments
        }

        return "std::make_tuple(" + deployments + ")"
    }

    def String getProxyOutArguments(FMethod _method, FInterface _interface, PropertyAccessor _accessor) {
        val boolean isDeployed = _method.hasDeployedArgument(_accessor, false, true)
        var String error = ""
        if (_method.hasError) {
            if (isDeployed) {
                error = "_error, "
            } else {
                error = _method.getErrorNameReference(_method.eContainer) + ", "
            }
        }

        if (isDeployed) {
            return "std::make_tuple(" + error + _method.outArgs.map["deploy_" + elementName].join(", ") + ")"
        } else {
            return "std::tuple<" + error + _method.outTypeList + ">()"
        }
    }

    def String generateDeployedStubSignature(FMethod _method, FInterface _interface, PropertyAccessor _accessor) {
        var String arguments = "const std::shared_ptr<CommonAPI::ClientId> _client"
        for (a : _method.inArgs) {
            arguments += ", const " + a.getDeployable(_interface, _accessor) + " &_" + a.name
        }
        arguments += ", " + _method.elementName + "WampReply_t _reply"
        return arguments
    }

    def generateWampStubReturnSignature(FMethod _method, FInterface _interface, PropertyAccessor _accessor) {
        var signature = ""

        if (_method.hasError)
            signature += _method.getErrorNameReference(_method.eContainer) + ' _error'
        if (_method.hasError && !_method.outArgs.empty)
            signature += ', '

        if (!_method.outArgs.empty)
            signature += _method.outArgs.map[getDeployable(_interface, _accessor) + ' _' + elementName].join(', ')

        return signature
    }

    def generateArgumentsToWampStub(FMethod _method, PropertyAccessor _accessor) {
        var arguments = ' _client'

        for (a : _method.inArgs) {
            if (_accessor.hasDeployment(a)) {
                arguments += ", _" + a.name + ".getValue()"
            } else {
                arguments += ", _" + a.name
            }
        }

        if (!_method.isFireAndForget)
            arguments = arguments + ', _reply'

        return arguments
    }

    ///////////////////////////////////////////////////////////
    // Get reference (C++ pointer) to a deployment parameter //
    ///////////////////////////////////////////////////////////
    def String getDeploymentRef(FTypedElement _typedElement, FModelElement _element, PropertyAccessor _accessor) {
        val String name = _typedElement.getDeploymentName(_element, null, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _typedElement.getDeploymentType(null, false) + "* >(nullptr)"
    }

    def String getDeploymentRef(FTypeRef _typeRef, PropertyAccessor _accessor) {
        val String name = _typeRef.getDeploymentName(null, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _typeRef.getDeploymentType(null, false) + "* >(nullptr)"
    }

    def String getDeploymentRef(FType _type, PropertyAccessor _accessor) {
        val String name = _type.getDeploymentName(null, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _type.getDeploymentType(null, false) + "* >(nullptr)"
    }

    def String getDeploymentRef(FBasicTypeId _typeId, PropertyAccessor _accessor) {
        val String name = _typeId.getDeploymentName(null, _accessor)
        if (name != "")
            return "&" + name

        return "static_cast< " + _typeId.getDeploymentType(null, false) + "* >(nullptr)"
    }

    // Error deployment
    def String getErrorDeploymentType(FMethod _method, boolean _isArgument) {
        var String deploymentType = ""
        if (_method.hasError) {
            deploymentType = "CommonAPI::EmptyDeployment"
            if (_isArgument && !_method.outArgs.empty)
                deploymentType = deploymentType + ", "
        }
        return deploymentType
    }

    def Set<String> getDeploymentInputIncludes(FInterface _interface, PropertyAccessor _accessor) {
       var Set<String> ret = new HashSet<String>()
       for(x: _interface.attributes) {
          if(x.type.derived != null) {
             ret.add(wampDeploymentHeaderPath(x.type.derived.eContainer as FTypeCollection))
          }
            if(x.type.derived instanceof FTypeDef) {
                addDeploymentHeaderforTypeDef((x.type.derived as FTypeDef), ret)
            }
       }
       for(x: _interface.broadcasts) {
           for(y: x.outArgs) {
              if(y.type.derived != null) {
                  ret.add(wampDeploymentHeaderPath(y.type.derived.eContainer as FTypeCollection))
              }
            if(y.type.derived instanceof FTypeDef) {
                addDeploymentHeaderforTypeDef((y.type.derived as FTypeDef), ret)
            }
           }
           if(x.hasDeployedArgument(_accessor)) {
                ret.add(_interface.wampDeploymentHeaderPath)
           }
       }
       for(x: _interface.methods) {
          for(y: x.outArgs) {
             if(y.type.derived != null) {
               ret.add(wampDeploymentHeaderPath(y.type.derived.eContainer as FTypeCollection))
             }
            if(y.type.derived instanceof FTypeDef) {
                addDeploymentHeaderforTypeDef((y.type.derived as FTypeDef), ret)
            }
          }
          for(y: x.inArgs) {
             if(y.type.derived != null) {
               ret.add(wampDeploymentHeaderPath(y.type.derived.eContainer as FTypeCollection))
             }
            if(y.type.derived instanceof FTypeDef) {
                addDeploymentHeaderforTypeDef((y.type.derived as FTypeDef), ret)
            }
          }
          if(x.hasDeployedArgument(_accessor, true, true)) {
                ret.add(_interface.wampDeploymentHeaderPath)
           }
       }
       return ret
    }

    def addDeploymentHeaderforTypeDef(FTypeDef typedef, Set<String> headers) {

        var derived = typedef.actualType.derived
        if(derived != null && (derived.eContainer as FTypeCollection) != null) {
            headers.add(wampDeploymentHeaderPath((typedef.actualType.derived.eContainer as FTypeCollection)))
        }
    }

}
