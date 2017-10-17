package org.genivi.commonapi.wamp.generator

import javax.inject.Inject
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FVersion
import org.genivi.commonapi.core.generator.FTypeGenerator
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor

import static com.google.common.base.Preconditions.*
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import java.util.List
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.franca.deploymodel.core.FDeployedProvider
import java.util.LinkedList

class FInterfaceWampProxyGenerator {
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaWampGeneratorExtensions

    var boolean generateSyncCalls = true

    def generateWampProxy(FInterface fInterface, IFileSystemAccess fileSystemAccess,
        PropertyAccessor deploymentAccessor, List<FDProvider> providers, IResource modelid) {

        if(FPreferencesWamp::getInstance.getPreference(PreferenceConstantsWamp::P_GENERATE_CODE_WAMP, "true").equals("true")) {
            generateSyncCalls = FPreferencesWamp::getInstance.getPreference(PreferenceConstantsWamp::P_GENERATE_SYNC_CALLS_WAMP, "true").equals("true")
            fileSystemAccess.generateFile(fInterface.wampProxyHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
                fInterface.generateWampProxyHeader(deploymentAccessor, modelid))
            fileSystemAccess.generateFile(fInterface.wampProxySourcePath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
                fInterface.generateWampProxySource(deploymentAccessor, providers, modelid))
        }
        else {
            // feature: suppress code generation
            fileSystemAccess.generateFile(fInterface.wampProxyHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp::NO_CODE)
            fileSystemAccess.generateFile(fInterface.wampProxySourcePath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp::NO_CODE)
        }
    }

    def private generateWampProxyHeader(FInterface fInterface, PropertyAccessor deploymentAccessor,
        IResource modelid) '''
        «generateCommonApiWampLicenseHeader()»
        «FTypeGenerator::generateComments(fInterface, false)»
        #ifndef «fInterface.defineName»_WAMP_PROXY_HPP_
        #define «fInterface.defineName»_WAMP_PROXY_HPP_

        #include <«fInterface.proxyBaseHeaderPath»>
        «IF fInterface.base != null»
            #include <«fInterface.base.wampProxyHeaderPath»>
        «ENDIF»
        #include "«fInterface.wampDeploymentHeaderPath»"

        #if !defined (COMMONAPI_INTERNAL_COMPILATION)
        #define COMMONAPI_INTERNAL_COMPILATION
        #endif

        #include <CommonAPI/Wamp/WampAddress.hpp>
        #include <CommonAPI/Wamp/WampFactory.hpp>
        #include <CommonAPI/Wamp/WampProxy.hpp>
        #include <CommonAPI/Wamp/WampAddressTranslator.hpp>
        «IF fInterface.hasAttributes»
            #include <CommonAPI/Wamp/WampAttribute.hpp>
            #include <CommonAPI/Wamp/WampFreedesktopAttribute.hpp>
        «ENDIF»
        «IF fInterface.hasBroadcasts»
            #include <CommonAPI/Wamp/WampEvent.hpp>
            «IF fInterface.hasSelectiveBroadcasts»
                #include <CommonAPI/Types.hpp>
                #include <CommonAPI/Wamp/WampSelectiveEvent.hpp>
            «ENDIF»
        «ENDIF»
        «IF !fInterface.managedInterfaces.empty»
            #include <CommonAPI/Wamp/WampProxyManager.hpp>
        «ENDIF»
        «IF !fInterface.attributes.filter[isVariant].empty»
            #include <CommonAPI/Wamp/WampDeployment.hpp>
        «ENDIF»

        #undef COMMONAPI_INTERNAL_COMPILATION

        #include <string>

        # if defined(_MSC_VER)
        #  if _MSC_VER >= 1300
        /*
         * Diamond inheritance is used for the CommonAPI::Proxy base class.
         * The Microsoft compiler put warning (C4250) using a desired c++ feature: "Delegating to a sister class"
         * A powerful technique that arises from using virtual inheritance is to delegate a method from a class in another class
         * by using a common abstract base class. This is also called cross delegation.
         */
        #    pragma warning( disable : 4250 )
        #  endif
        # endif

        «fInterface.generateVersionNamespaceBegin»
        «fInterface.model.generateNamespaceBeginDeclaration»

        class «fInterface.wampProxyClassName»
            : virtual public «fInterface.proxyBaseClassName»,
              virtual public «IF fInterface.base != null»«fInterface.base.getTypeCollectionName(fInterface)»WampProxy«ELSE»CommonAPI::Wamp::WampProxy«ENDIF» {
        public:
            «fInterface.wampProxyClassName»(
                const CommonAPI::Wamp::WampAddress &_address,
                const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection);

            virtual ~«fInterface.wampProxyClassName»() { }

            «FOR attribute : fInterface.attributes»
            virtual «attribute.generateGetMethodDefinition»;
            «ENDFOR»

            «FOR broadcast : fInterface.broadcasts»
                virtual «broadcast.generateGetMethodDefinition»;
            «ENDFOR»

            «FOR method : fInterface.methods»
            «FTypeGenerator::generateComments(method, false)»
            «IF generateSyncCalls || method.isFireAndForget»
            virtual «method.generateDefinition(false)»;
            «ENDIF»
            «IF !method.isFireAndForget»
                virtual «method.generateAsyncDefinition(false)»;
            «ENDIF»
            «ENDFOR»

            «FOR managed : fInterface.managedInterfaces»
            virtual CommonAPI::ProxyManager& «managed.proxyManagerGetterName»();
            «ENDFOR»

            virtual void getOwnVersion(uint16_t& ownVersionMajor, uint16_t& ownVersionMinor) const;

        private:

            «FOR attribute : fInterface.attributes»
                «IF attribute.supportsTypeValidation»
                class Wamp«attribute.wampClassVariableName»Attribute : public «attribute.wampClassName(deploymentAccessor, fInterface)» {
                public:
                template <typename... _A>
                    Wamp«attribute.wampClassVariableName»Attribute(WampProxy &_proxy,
                        _A ... arguments)
                        : «attribute.wampClassName(deploymentAccessor, fInterface)»(
                            _proxy, arguments...) {}
                «IF !attribute.isReadonly »
                void setValue(const «attribute.getTypeName(fInterface, true)»& requestValue,
                    CommonAPI::CallStatus& callStatus,
                    «attribute.getTypeName(fInterface, true)»& responseValue,
                    const CommonAPI::CallInfo *_info = nullptr) {
                        // validate input parameters
                        if (!requestValue.validate()) {
                            callStatus = CommonAPI::CallStatus::INVALID_VALUE;
                            return;
                        }
                        // call parent function if ok
                        «attribute.wampClassName(deploymentAccessor, fInterface)»::setValue(requestValue, callStatus, responseValue, _info);
                    }
                std::future<CommonAPI::CallStatus> setValueAsync(const «attribute.getTypeName(fInterface, true)»& requestValue,
                    std::function<void(const CommonAPI::CallStatus &, «attribute.getTypeName(fInterface, true)»)> _callback,
                    const CommonAPI::CallInfo *_info) {
                        // validate input parameters
                        if (!requestValue.validate()) {
                            «attribute.getTypeName(fInterface, true)» _returnvalue;
                            _callback(CommonAPI::CallStatus::INVALID_VALUE, _returnvalue);
                            std::promise<CommonAPI::CallStatus> promise;
                            promise.set_value(CommonAPI::CallStatus::INVALID_VALUE);
                            return promise.get_future();
                        }
                        // call parent function if ok
                        return «attribute.wampClassName(deploymentAccessor, fInterface)»::setValueAsync(requestValue, _callback, _info);
                    }
                «ENDIF»
                };
                Wamp«attribute.wampClassVariableName»Attribute «attribute.wampClassVariableName»;
                «ELSE»
                «attribute.wampClassName(deploymentAccessor, fInterface)» «attribute.wampClassVariableName»;
                «ENDIF»
            «ENDFOR»

            «FOR broadcast : fInterface.broadcasts»
                «IF !broadcast.isErrorType(deploymentAccessor)»
                    «broadcast.wampClassName(deploymentAccessor, fInterface)» «broadcast.wampClassVariableName»;
                «ELSE»
                
                typedef «broadcast.wampErrorEventClassName(deploymentAccessor, fInterface)» «broadcast.wampErrorEventTypedefName(deploymentAccessor)»;
                «broadcast.wampErrorEventTypedefName(deploymentAccessor)» «broadcast.wampClassVariableName»;
                «ENDIF»
            «ENDFOR»

            «FOR managed : fInterface.managedInterfaces»
            CommonAPI::Wamp::WampProxyManager «managed.proxyManagerMemberName»;
            «ENDFOR»
        };

        «fInterface.model.generateNamespaceEndDeclaration»
        «fInterface.generateVersionNamespaceEnd»

        #endif // «fInterface.defineName»_WAMP_PROXY_HPP_

    '''

    def private generateWampProxySource(FInterface fInterface, PropertyAccessor deploymentAccessor, List<FDProvider> providers,
        IResource modelid) '''
        «generateCommonApiWampLicenseHeader()»
        «FTypeGenerator::generateComments(fInterface, false)»
        #include <«fInterface.wampProxyHeaderPath»>

        «fInterface.generateVersionNamespaceBegin»
        «fInterface.model.generateNamespaceBeginDeclaration»

        std::shared_ptr<CommonAPI::Wamp::WampProxy> create«fInterface.wampProxyClassName»(
            const CommonAPI::Wamp::WampAddress &_address,
            const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection) {
            return std::make_shared< «fInterface.wampProxyClassName»>(_address, _connection);
        }

        void initialize«fInterface.wampProxyClassName»() {
             «FOR p : providers»
                 «val PropertyAccessor providerAccessor = new PropertyAccessor(new FDeployedProvider(p))»
                 «FOR i : p.instances.filter[target == fInterface]»
                     CommonAPI::Wamp::WampAddressTranslator::get()->insert(
                         "local:«fInterface.fullyQualifiedNameWithVersion»:«providerAccessor.getInstanceId(i)»",
                         "«providerAccessor.getWampServiceName(i)»",
                         "«providerAccessor.getWampObjectPath(i)»",
                         "«providerAccessor.getWampInterfaceName(i)»");
                 «ENDFOR»
             «ENDFOR»
             CommonAPI::Wamp::Factory::get()->registerProxyCreateMethod(
                «fInterface.elementName»::getInterface(),
                &create«fInterface.wampProxyClassName»);
        }

        INITIALIZER(register«fInterface.wampProxyClassName») {
            CommonAPI::Wamp::Factory::get()->registerInterface(initialize«fInterface.wampProxyClassName»);
        }

        «fInterface.wampProxyClassName»::«fInterface.wampProxyClassName»(
            const CommonAPI::Wamp::WampAddress &_address,
            const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection)
            :   CommonAPI::Wamp::WampProxy(_address, _connection)«IF fInterface.base != null»,«ENDIF»
                «fInterface.generateWampBaseInstantiations»
                «FOR attribute : fInterface.attributes BEFORE ',' SEPARATOR ','»
                    «attribute.generateWampVariableInit(deploymentAccessor, fInterface)»
                «ENDFOR»
                «FOR broadcast : fInterface.broadcasts BEFORE ',' SEPARATOR ','»
                    «IF !broadcast.isErrorType(deploymentAccessor)»
                        «broadcast.wampClassVariableName»(*this, "«broadcast.elementName»", "«broadcast.wampSignature(deploymentAccessor)»", «broadcast.
                getDeployments(fInterface, deploymentAccessor)»)
                    «ELSE»
                        «broadcast.wampClassVariableName»(«broadcast.wampErrorEventTypedefName(deploymentAccessor)»("«deploymentAccessor.getErrorName(broadcast)»"«IF !broadcast.errorArgs(deploymentAccessor).empty», std::make_tuple(«broadcast.errorArgs(deploymentAccessor).map[getDeploymentRef(it.array, broadcast, fInterface, deploymentAccessor)].join(', ')»)«ENDIF»))
                    «ENDIF»
                «ENDFOR»
                «FOR managed : fInterface.managedInterfaces BEFORE ',' SEPARATOR ','»
                    «managed.proxyManagerMemberName»(*this, "«managed.fullyQualifiedName».«managed.interfaceVersion»","«managed.fullyQualifiedNameWithVersion»")
                «ENDFOR»
        {
            «FOR p : providers»
                «val PropertyAccessor providerAccessor = new PropertyAccessor(new FDeployedProvider(p))»
                «FOR i : p.instances.filter[target == fInterface]»
                    CommonAPI::Wamp::WampServiceRegistry::get(_connection)->setWampServicePredefined(_address.getService());
                «ENDFOR»
            «ENDFOR»
        }

              «FOR attribute : fInterface.attributes»
                  «attribute.generateGetMethodDefinitionWithin(fInterface.wampProxyClassName)» {
                      return «attribute.wampClassVariableName»;
                  }
              «ENDFOR»

              «FOR broadcast : fInterface.broadcasts»
            «broadcast.generateGetMethodDefinitionWithin(fInterface.wampProxyClassName)» {
                return «broadcast.wampClassVariableName»;
            }
              «ENDFOR»

            «FOR method : fInterface.methods»
                «var errorClasses = new LinkedList()»
                «FOR broadcast : fInterface.broadcasts»
                    «IF broadcast.isErrorType(method, deploymentAccessor)»
                        «{errorClasses.add('&' + broadcast.wampClassVariableName);""}»
                    «ENDIF»
                «ENDFOR»
                «val timeout = method.getTimeout(deploymentAccessor)»
                «val inParams = method.generateInParams(deploymentAccessor)»
                «IF generateSyncCalls || method.isFireAndForget»
                «val outParams = method.generateOutParams(deploymentAccessor, false)»
                «FTypeGenerator::generateComments(method, false)»
                «method.generateDefinitionWithin(fInterface.wampProxyClassName, false)» {
                    «method.generateProxyHelperDeployments(fInterface, false, deploymentAccessor)»
                    «IF method.isFireAndForget»
                        «method.generateWampProxyHelperClass(fInterface, deploymentAccessor)»::callMethod(
                    «ELSE»
                        «IF timeout != 0»
                            static CommonAPI::CallInfo info(«timeout»);
                        «ENDIF»
                        «method.generateWampProxyHelperClass(fInterface, deploymentAccessor)»::callMethodWithReply(
                    «ENDIF»
                    *this,
                    "«method.elementName»",
                    "«method.wampInSignature(deploymentAccessor)»",
            «IF !method.isFireAndForget»(_info ? _info : «IF timeout != 0»&info«ELSE»&CommonAPI::Wamp::defaultCallInfo«ENDIF»),«ENDIF»
            «IF inParams != ""»«inParams»,«ENDIF»
            _internalCallStatus«IF method.hasError»,
            deploy_error«ENDIF»«IF outParams != ""»,
            «outParams»«ENDIF»«IF !method.isFireAndForget && !errorClasses.empty»,
            «'std::make_tuple(' + errorClasses.map[it].join(', ') + ')'»«ENDIF»);
            «method.generateOutParamsValue(deploymentAccessor)»
            }
            «ENDIF»
            «IF !method.isFireAndForget»
                «method.generateAsyncDefinitionWithin(fInterface.wampProxyClassName, false)» {
                    «method.generateProxyHelperDeployments(fInterface, true, deploymentAccessor)»
                    «IF timeout != 0»
                        static CommonAPI::CallInfo info(«timeout»);
                    «ENDIF»
                    return «method.generateWampProxyHelperClass(fInterface, deploymentAccessor)»::callMethodAsync(
                    *this,
                    "«method.elementName»",
                    "«method.wampInSignature(deploymentAccessor)»",
                    (_info ? _info : «IF timeout != 0»&info«ELSE»&CommonAPI::Wamp::defaultCallInfo«ENDIF»),
                    «IF inParams != ""»«inParams»,«ENDIF»
                    «method.generateCallback(fInterface, deploymentAccessor)»«IF !errorClasses.empty»,
                    «'std::make_tuple(' + errorClasses.map[it].join(', ') + ')'»«ENDIF»);
                }
            «ENDIF»
              «ENDFOR»

        «FOR managed : fInterface.managedInterfaces»
            CommonAPI::ProxyManager& «fInterface.wampProxyClassName»::«managed.proxyManagerGetterName»() {
            return «managed.proxyManagerMemberName»;
                  }
        «ENDFOR»

        void «fInterface.wampProxyClassName»::getOwnVersion(uint16_t& ownVersionMajor, uint16_t& ownVersionMinor) const {
                  «val FVersion itsVersion = fInterface.version»
                  «IF itsVersion != null»
                      ownVersionMajor = «fInterface.version.major»;
                      ownVersionMinor = «fInterface.version.minor»;
                  «ELSE»
                      ownVersionMajor = 0;
                      ownVersionMinor = 0;
                  «ENDIF»
              }

              «fInterface.model.generateNamespaceEndDeclaration»
              «fInterface.generateVersionNamespaceEnd»
     '''

    def private wampClassVariableName(FModelElement fModelElement) {
        checkArgument(!fModelElement.elementName.nullOrEmpty, 'FModelElement has no name: ' + fModelElement)
        fModelElement.elementName.toFirstLower + '_'
    }

    def private wampClassVariableName(FBroadcast fBroadcast) {
        checkArgument(!fBroadcast.elementName.nullOrEmpty, 'FModelElement has no name: ' + fBroadcast)
        var classVariableName = fBroadcast.elementName.toFirstLower

        if (fBroadcast.selective)
            classVariableName = classVariableName + 'Selective'

        classVariableName = classVariableName + '_'

        return classVariableName
    }
    
    def private wampErrorEventTypedefName(FBroadcast fBroadcast, PropertyAccessor deploymentAccessor) {
        checkArgument(fBroadcast.isErrorType(deploymentAccessor), 'FBroadcast is no error type: ' + fBroadcast)
        
        return 'Wamp' + fBroadcast.className
    }

    def private wampProxyHeaderFile(FInterface fInterface) {
        fInterface.elementName + "WampProxy.hpp"
    }

    def private wampProxyHeaderPath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampProxyHeaderFile
    }

    def private wampProxySourceFile(FInterface fInterface) {
        fInterface.elementName + "WampProxy.cpp"
    }

    def private wampProxySourcePath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampProxySourceFile
    }

    def private wampProxyClassName(FInterface fInterface) {
        fInterface.elementName + 'WampProxy'
    }

    def private generateWampProxyHelperClass(FMethod fMethod,
        FInterface _interface, PropertyAccessor _accessor) '''
        «var errorEventTypedefs = new LinkedList()»
        «FOR broadcast : _interface.broadcasts»
            «IF broadcast.isErrorType(fMethod, _accessor)»
                «{errorEventTypedefs.add(broadcast.wampErrorEventTypedefName(_accessor));""}»
            «ENDIF»
        «ENDFOR»
    CommonAPI::Wamp::WampProxyHelper<
        CommonAPI::Wamp::WampSerializableArguments<
        «FOR a : fMethod.inArgs»
            CommonAPI::Deployable< «a.getTypeName(fMethod, true)», «a.getDeploymentType(_interface, true)» >«IF a != fMethod.inArgs.last»,«ENDIF»
        «ENDFOR»
        >,
        CommonAPI::Wamp::WampSerializableArguments<
        «IF fMethod.hasError»
            CommonAPI::Deployable< «fMethod.errorType», «fMethod.getErrorDeploymentType(false)»>«IF !fMethod.outArgs.empty»,«ENDIF»
        «ENDIF»
        «FOR a : fMethod.outArgs»
            CommonAPI::Deployable< «a.getTypeName(fMethod, true)»,«a.getDeploymentType(_interface, true)»>«IF a != fMethod.outArgs.last»,«ENDIF»
        «ENDFOR»
        >«IF !errorEventTypedefs.empty»,«ENDIF»
        «errorEventTypedefs.map[it].join(',\n')»
        >'''

    def private wampClassName(FAttribute fAttribute, PropertyAccessor deploymentAccessor, FInterface fInterface) {
        var type = 'CommonAPI::Wamp::Wamp'
        type = type + 'Freedesktop'

        if (fAttribute.isReadonly)
            type = type + 'Readonly'

        type = type + "Attribute<" + fAttribute.className
        val deployment = fAttribute.getDeploymentType(fInterface, true)
        if(!deployment.equals("CommonAPI::EmptyDeployment")) type += ", " + deployment
        type += ">"

        if (fAttribute.isObservable)
            type = 'CommonAPI::Wamp::WampFreedesktopObservableAttribute<' + type + '>'

        return type
    }

    def private generateWampVariableInit(FAttribute fAttribute, PropertyAccessor deploymentAccessor,
        FInterface fInterface) {
        var ret = fAttribute.wampClassVariableName + '(*this'

        ret = ret + ', getWampAddress().getInterface(), "' + fAttribute.elementName + '"'
        val String deployment = fAttribute.getDeploymentRef(fAttribute.array, null, fInterface, deploymentAccessor)
        if (deployment != "")
            ret += ", " + deployment

        ret += ")"
        return ret
    }

    def private wampClassName(FBroadcast fBroadcast, PropertyAccessor deploymentAccessor, FInterface fInterface) {
        var ret = 'CommonAPI::Wamp::'

        if (fBroadcast.isSelective)
            ret = ret + 'WampSelectiveEvent'
        else
            ret = ret + 'WampEvent'

        ret = ret + '<' + fBroadcast.className

        for (a : fBroadcast.outArgs) {
            ret += ", "
            ret += a.getDeployable(fInterface, deploymentAccessor)
        }

        ret = ret + '>'

        return ret
    }
    
    def private wampErrorEventClassName(FBroadcast fBroadcast, PropertyAccessor deploymentAccessor, FInterface fInterface) {
        checkArgument(fBroadcast.isErrorType(deploymentAccessor), 'FBroadcast is no error type: ' + fBroadcast)

        var ret = 'CommonAPI::Wamp::WampErrorEvent<\n'
        if (fBroadcast.outArgs.size > 1) {
            ret = ret + '    std::tuple< ' + fBroadcast.errorArgs(deploymentAccessor).map[it.getTypeName(fInterface, true)].join(', ') + '>,\n'
            ret = ret + '    std::tuple< ' + fBroadcast.errorArgs(deploymentAccessor).map[it.getDeploymentType(fInterface, true)].join(', ') + '>\n'
        }
        return ret + '>'
    }

    def private generateProxyHelperDeployments(FMethod _method,
        FInterface _interface, boolean _isAsync,
        PropertyAccessor _accessor) '''
        «IF _method.hasError»
            CommonAPI::Deployable< «_method.errorType», «_method.getErrorDeploymentType(false)»> deploy_error(«_method.
            getErrorDeploymentRef(_interface, _accessor)»);
        «ENDIF»
        «FOR a : _method.inArgs»
            CommonAPI::Deployable< «a.getTypeName(_method, true)», «a.getDeploymentType(_interface, true)»> deploy_«a.name»(_«a.
            name», «a.getDeploymentRef(a.array, _method, _interface, _accessor)»);
        «ENDFOR»
        «FOR a : _method.outArgs»
            CommonAPI::Deployable< «a.getTypeName(_method, true)», «a.getDeploymentType(_interface, true)»> deploy_«a.name»(«a.
            getDeploymentRef(a.array, _method, _interface, _accessor)»);
        «ENDFOR»
    '''

    def private generateInParams(FMethod _method, PropertyAccessor _accessor) {
        var String inParams = ""
        for (a : _method.inArgs) {
            if(inParams != "") inParams += ", "
            inParams += "deploy_" + a.name
        }
        return inParams
    }

    def private generateOutParams(FMethod _method, PropertyAccessor _accessor,
        boolean _instantiate) {
        var String outParams = ""
        for (a : _method.outArgs) {
            if(outParams != "") outParams += ", "
            outParams += "deploy_" + a.name
        }
        return outParams
    }

    def private generateOutParamsValue(FMethod _method,
        PropertyAccessor _accessor) {
        var String outParamsValue = ""
        if (_method.hasError) {
            outParamsValue += "_error = deploy_error.getValue();\n"
        }
        for (a : _method.outArgs) {
            outParamsValue += "_" + a.name + " = deploy_" + a.name + ".getValue();\n"
        }
        return outParamsValue
    }

    def private generateCallback(FMethod _method, FInterface _interface,
        PropertyAccessor _accessor) {

        var String error = ""
        if (_method.hasError) {
            error = "deploy_error"
        }

        var String callback = "[_callback] (" + generateCallbackParameter(_method, _interface, _accessor) + ") {\n"
        callback += "    if (_callback)\n"
        callback += "        _callback(_internalCallStatus"
        if(_method.hasError) callback += ", _deploy_error.getValue()"
        for (a : _method.outArgs) {
            callback += ", _" + a.name
            callback += ".getValue()"
        }
        callback += ");\n"
        callback += "},\n"

        var String out = generateOutParams(_method, _accessor, true)
        if(error != "" && out != "") error += ", "
        callback += "std::make_tuple(" + error + out + ")"
        return callback
    }

    def private generateCallbackParameter(FMethod _method,
        FInterface _interface, PropertyAccessor _accessor) {
        var String declaration = "CommonAPI::CallStatus _internalCallStatus"
        if (_method.hasError)
            declaration +=
                ", CommonAPI::Deployable< " + _method.errorType + ", " + _method.getErrorDeploymentType(false) +
                    " > _deploy_error"
        for (a : _method.outArgs) {
            declaration += ", "
            declaration += "CommonAPI::Deployable< " + a.getTypeName(_method, true) + ", " +
                a.getDeploymentType(_interface, true) + " > _" + a.name
        }
        return declaration
    }

}
