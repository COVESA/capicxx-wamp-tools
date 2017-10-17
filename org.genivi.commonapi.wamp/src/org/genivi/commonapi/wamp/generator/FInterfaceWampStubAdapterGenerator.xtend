package org.genivi.commonapi.wamp.generator

import java.util.HashMap
import javax.inject.Inject
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement
import org.genivi.commonapi.core.generator.FTypeGenerator
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import java.util.List
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.franca.deploymodel.core.FDeployedProvider
import java.util.LinkedList

class FInterfaceWampStubAdapterGenerator {
	@Inject private extension FrancaGeneratorExtensions
	@Inject private extension FrancaWampGeneratorExtensions
	@Inject private extension FrancaWampDeploymentAccessorHelper

	def generateWampStubAdapter(FInterface _interface, IFileSystemAccess fileSystemAccess, PropertyAccessor deploymentAccessor,  List<FDProvider> providers, IResource modelid) {

		if(FPreferencesWamp::getInstance.getPreference(PreferenceConstantsWamp::P_GENERATE_CODE_WAMP, "true").equals("true")) {
			fileSystemAccess.generateFile(_interface.wampStubAdapterHeaderPath, PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP,
					_interface.generateWampStubAdapterHeader(deploymentAccessor, modelid))
			fileSystemAccess.generateFile(_interface.wampStubAdapterSourcePath,  PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP,
					_interface.generateWampStubAdapterSource(deploymentAccessor, providers, modelid))
		}
		else {
			// feature: suppress code generation
			fileSystemAccess.generateFile(_interface.wampStubAdapterHeaderPath, PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, PreferenceConstantsWamp::NO_CODE)
			fileSystemAccess.generateFile(_interface.wampStubAdapterSourcePath,  PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, PreferenceConstantsWamp::NO_CODE)
		}
	}


	def private generateWampStubAdapterHeader(FInterface _interface,
											  PropertyAccessor deploymentAccessor,
											  IResource modelid ) '''
		«generateCommonApiWampLicenseHeader()»
		«FTypeGenerator::generateComments(_interface, false)»
		#ifndef «_interface.defineName»_WAMP_STUB_ADAPTER_HPP_
		#define «_interface.defineName»_WAMP_STUB_ADAPTER_HPP_

		#include "«_interface.stubHeaderPath»"
		«IF _interface.base != null»
			#include "«_interface.base.wampStubAdapterHeaderPath»"
		«ENDIF»
		//#include "«_interface.wampDeploymentHeaderPath»"

		#if !defined (COMMONAPI_INTERNAL_COMPILATION)
		#define COMMONAPI_INTERNAL_COMPILATION
		#endif

		#include <CommonAPI/Wamp/WampFactory.hpp>
		«IF !_interface.managedInterfaces.empty»
			#include <CommonAPI/Wamp/WampObjectManager.hpp>
		«ENDIF»
		#include <CommonAPI/Wamp/WampStubAdapterHelper.hpp>
		#include <CommonAPI/Wamp/WampStubAdapter.hpp>
		//#include <CommonAPI/Wamp/WampDeployment.hpp>

		#undef COMMONAPI_INTERNAL_COMPILATION

		#include <autobahn/autobahn.hpp>

		«_interface.generateVersionNamespaceBegin»
		«_interface.model.generateNamespaceBeginDeclaration»

		typedef CommonAPI::Wamp::WampStubAdapterHelper<«_interface.stubClassName»> «_interface.wampStubAdapterHelperClassName»;

		class «_interface.wampStubAdapterClassNameInternal»
			: public virtual «_interface.stubAdapterClassName»,
			  public «_interface.wampStubAdapterHelperClassName»«IF _interface.base != null»,
			  public «_interface.base.getTypeCollectionName(_interface)»WampStubAdapterInternal«ENDIF»
		{
		public:
			«_interface.wampStubAdapterClassNameInternal»(
				const CommonAPI::Wamp::WampAddress &_address,
				const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection,
				const std::shared_ptr<CommonAPI::StubBase> &_stub);

			~«_interface.wampStubAdapterClassNameInternal»();

			//////////////////////////////////////////////////////////////////////////////////////////

			virtual void provideRemoteMethods();

			«FOR method : _interface.methods»
			void wrap_«method.name»(autobahn::wamp_invocation invocation);
			«ENDFOR»

			//////////////////////////////////////////////////////////////////////////////////////////

			const «_interface.wampStubAdapterHelperClassName»::StubDispatcherTable& getStubDispatcherTable();
			const CommonAPI::Wamp::StubAttributeTable& getStubAttributeTable();

			void deactivateManagedInstances();

			static CommonAPI::Wamp::WampGetAttributeStubDispatcher<
				«_interface.stubFullClassName»,
				CommonAPI::Version
			> get«_interface.elementName»InterfaceVersionStubDispatcher;

			«var counterMap = new HashMap<String, Integer>()»
			«var methodNumberMap = new HashMap<FMethod, Integer>()»
			«_interface.generateMethodDispatcherDeclarations(_interface, counterMap, methodNumberMap)»

		private:
			«_interface.wampStubAdapterHelperClassName»::StubDispatcherTable stubDispatcherTable_;
			CommonAPI::Wamp::StubAttributeTable stubAttributeTable_;
		};


		class «_interface.wampStubAdapterClassName»
			: public «_interface.wampStubAdapterClassNameInternal»,
			  public std::enable_shared_from_this<«_interface.wampStubAdapterClassName»> {
		public:
			«_interface.wampStubAdapterClassName»(const CommonAPI::Wamp::WampAddress &_address,
													const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection,
													const std::shared_ptr<CommonAPI::StubBase> &_stub) 
				: CommonAPI::Wamp::WampStubAdapter(_address, _connection, false),
				  «_interface.wampStubAdapterClassNameInternal»(_address, _connection, _stub) {
				std::cout << "«_interface.wampStubAdapterClassName» constructor called" << std::endl;
			}
		};

		«_interface.model.generateNamespaceEndDeclaration»
		«_interface.generateVersionNamespaceEnd»

		#endif // «_interface.defineName»_WAMP_STUB_ADAPTER_HPP_
	'''


	def private String generateMethodDispatcherDeclarations(FInterface _interface,
															FInterface _container,
															HashMap<String, Integer> _counters, 
															HashMap<FMethod, Integer> _methods) '''
		«val accessor = getAccessor(_interface)»						   
		«FOR method : _interface.methods»			  
			«FTypeGenerator::generateComments(method, false)»
			«IF !method.isFireAndForget»
				static CommonAPI::Wamp::MethodWithReplyStubDispatcher<
					«_interface.stubFullClassName»,
					std::tuple<>,
					std::tuple<>,
					std::tuple<>,
					std::tuple<>
					«IF !(_counters.containsKey(method.wampStubDispatcherVariable))»
						«{_counters.put(method.wampStubDispatcherVariable, 0);  _methods.put(method, 0);""}»
				> «method.wampStubDispatcherVariable»;
				«ELSE»
					«{_counters.put(method.wampStubDispatcherVariable, _counters.get(method.wampStubDispatcherVariable) + 1);  _methods.put(method, _counters.get(method.wampStubDispatcherVariable));""}»
				> «method.wampStubDispatcherVariable»«Integer::toString(_counters.get(method.wampStubDispatcherVariable))»;
				«ENDIF»
			«ELSE»
				static CommonAPI::SomeIP::MethodStubDispatcher<
					«_interface.stubFullClassName»,
					std::tuple<«method.allInTypes»>,
					std::tuple<«method.inArgs.getDeploymentTypes(_interface, accessor)»>
					«IF !(_counters.containsKey(method.wampStubDispatcherVariable))»
						«{_counters.put(method.wampStubDispatcherVariable, 0); _methods.put(method, 0);""}»
				> «method.wampStubDispatcherVariable»;
				«ELSE»
					«{_counters.put(method.wampStubDispatcherVariable, _counters.get(method.wampStubDispatcherVariable) + 1);  _methods.put(method, _counters.get(method.wampStubDispatcherVariable));""}»
				> «method.wampStubDispatcherVariable»«Integer::toString(_counters.get(method.wampStubDispatcherVariable))»;
				«ENDIF»
			«ENDIF»
		«ENDFOR»
	'''


	def private generateWampStubAdapterSource(FInterface _interface, PropertyAccessor deploymentAccessor,  List<FDProvider> providers, IResource modelid) '''
		«generateCommonApiWampLicenseHeader()»
		#include <«_interface.headerPath»>
		#include <«_interface.wampStubAdapterHeaderPath»>

		«_interface.generateVersionNamespaceBegin»
		«_interface.model.generateNamespaceBeginDeclaration»


		«_interface.model.generateNamespaceEndDeclaration»
		«_interface.generateVersionNamespaceEnd»
	'''

	def private getAbsoluteNamespace(FModelElement fModelElement) {
		fModelElement.model.name.replace('.', '::')
	}

	def private wampStubAdapterHeaderFile(FInterface _interface) {
		_interface.elementName + "WampStubAdapter.hpp"
	}

	def private wampStubAdapterHeaderPath(FInterface _interface) {
		_interface.versionPathPrefix + _interface.model.directoryPath + '/' + _interface.wampStubAdapterHeaderFile
	}

	def private wampStubAdapterSourceFile(FInterface _interface) {
		_interface.elementName + "WampStubAdapter.cpp"
	}

	def private wampStubAdapterSourcePath(FInterface _interface) {
		_interface.versionPathPrefix + _interface.model.directoryPath + '/' + _interface.wampStubAdapterSourceFile
	}

	def private wampStubAdapterClassName(FInterface _interface) {
		_interface.elementName + 'WampStubAdapter'
	}

	def private wampStubAdapterClassNameInternal(FInterface _interface) {
		_interface.wampStubAdapterClassName + 'Internal'
	}

	def private wampStubAdapterHelperClassName(FInterface _interface) {
		_interface.elementName + 'WampStubAdapterHelper'
	}

	def private getAllInTypes(FMethod fMethod) {
		fMethod.inArgs.map[getTypeName(fMethod, true)].join(', ')
	}

	def private getAllOutTypes(FMethod fMethod) {
		var types = fMethod.outArgs.map[getTypeName(fMethod, true)].join(', ')

		if (fMethod.hasError) {
			if (!fMethod.outArgs.empty)
				types = ', ' + types
			types = fMethod.getErrorNameReference(fMethod.eContainer) + types
		}

		return types
	}

	def private wampStubDispatcherVariable(FMethod fMethod) {
		fMethod.elementName.toFirstLower + 'StubDispatcher'
	}

	def private wampGetStubDispatcherVariable(FAttribute fAttribute) {
		fAttribute.wampGetMethodName + 'StubDispatcher'
	}

	def private wampSetStubDispatcherVariable(FAttribute fAttribute) {
		fAttribute.wampSetMethodName + 'StubDispatcher'
	}

	def private wampStubDispatcherVariable(FBroadcast fBroadcast) {
		var returnVal = fBroadcast.elementName.toFirstLower

		if(fBroadcast.selective)
			returnVal = returnVal + 'Selective'

		returnVal = returnVal + 'StubDispatcher'

		return returnVal
	}

	def private wampStubDispatcherVariableSubscribe(FBroadcast fBroadcast) {
		"subscribe" + fBroadcast.wampStubDispatcherVariable.toFirstUpper
	}

	def private wampStubDispatcherVariableUnsubscribe(FBroadcast fBroadcast) {
		"unsubscribe" + fBroadcast.wampStubDispatcherVariable.toFirstUpper
	}

	var nextSectionInDispatcherNeedsComma = false;

	def void setNextSectionInDispatcherNeedsComma(boolean newValue) {
		nextSectionInDispatcherNeedsComma = newValue
	}

	def private generateFireChangedMethodBody(FAttribute attribute, FInterface _interface, PropertyAccessor deploymentAccessor) '''
		«val String deploymentType = attribute.getDeploymentType(_interface, true)»
		«val String deployment = attribute.getDeploymentRef(attribute.array, null, _interface, deploymentAccessor)»
		«IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»
		CommonAPI::Deployable< «attribute.getTypeName(attribute, true)», «deploymentType»> deployedValue(value, «IF deployment != ""»«deployment»«ELSE»nullptr«ENDIF»);
		«ENDIF»
		CommonAPI::Wamp::WampStubSignalHelper<CommonAPI::Wamp::WampSerializableArguments<
		«IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»
			CommonAPI::Deployable<
				«attribute.getTypeName(_interface, true)»,
				«deploymentType»
			>
		«ELSE»
			«attribute.getTypeName(_interface, true)»
		«ENDIF»
		>>
			::sendSignal(
				*this,
				"«attribute.wampSignalName»",
				"«attribute.wampSignature(deploymentAccessor)»",
				«IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»deployedValue«ELSE»value«ENDIF»

		);
	'''

	def private generateStubAttributeTableInitializer(FInterface _interface, PropertyAccessor deploymentAccessor) '''
		«IF !_interface.attributes.empty»
			«FOR attribute : _interface.attributes»
				«_interface.generateStubAttributeTableInitializerEntry(attribute)»
			«ENDFOR»
		«ENDIF»
	'''

	def private generateStubAttributeTableInitializerEntry(FInterface _interface, FAttribute fAttribute) '''
		«_interface.wampStubAdapterHelperClassName»::addAttributeDispatcher("«fAttribute.elementName»",
				&«_interface.absoluteNamespace»::«_interface.wampStubAdapterClassNameInternal»<_Stub, _Stubs...>::«fAttribute.wampGetStubDispatcherVariable»,
				«IF fAttribute.readonly»(CommonAPI::Wamp::WampSetFreedesktopAttributeStubDispatcher<«_interface.stubFullClassName», int>*)NULL«ELSE»&«_interface.absoluteNamespace»::«_interface.wampStubAdapterClassNameInternal»<_Stub, _Stubs...>::«fAttribute.wampSetStubDispatcherVariable»«ENDIF»
			);
	'''
	
	def private generateErrorReplyCallback(FBroadcast fBroadcast, FInterface _interface, FMethod fMethod, PropertyAccessor deploymentAccessor) '''
			
		static void «fBroadcast.errorReplyCallbackName(deploymentAccessor)»(«fBroadcast.generateErrorReplyCallbackSignature(fMethod, deploymentAccessor)») {
			«IF fBroadcast.errorArgs(deploymentAccessor).size > 1»
				auto args = std::make_tuple(
					«fBroadcast.errorArgs(deploymentAccessor).map[it.getDeployable(_interface, deploymentAccessor) + '(' + '_' + it.elementName + ', ' + getDeploymentRef(it.array, fBroadcast, _interface, deploymentAccessor) + ')'].join(",\n")  + ");"»
			«ELSE»
				auto args = std::make_tuple();
			«ENDIF»
			«fMethod.wampStubDispatcherVariable».sendErrorReply(_callId, "«fBroadcast.wampErrorReplyOutSignature(fMethod, deploymentAccessor)»", _«fBroadcast.errorName(deploymentAccessor)», args);
		}
	'''
	
}
