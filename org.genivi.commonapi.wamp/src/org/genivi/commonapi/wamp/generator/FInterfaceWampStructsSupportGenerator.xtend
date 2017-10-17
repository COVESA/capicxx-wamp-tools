package org.genivi.commonapi.wamp.generator

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp

import static extension org.franca.core.framework.FrancaHelpers.*

class FInterfaceWampStructsSupportGenerator {
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaWampGeneratorExtensions
    @Inject private extension FrancaWampTypeExtensions

    def generateWampStructsSupport(FInterface fInterface, IFileSystemAccess fileSystemAccess,
        PropertyAccessor deploymentAccessor, List<FDProvider> providers, IResource modelid) {

        if(FPreferencesWamp::getInstance.getPreference(PreferenceConstantsWamp::P_GENERATE_CODE_WAMP, "true").equals("true")) {
            fileSystemAccess.generateFile(fInterface.wampStructsSupportHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
                fInterface.generateHeader(deploymentAccessor, modelid))
            fileSystemAccess.generateFile(fInterface.wampStructsSupportSourcePath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
                fInterface.generateSource(deploymentAccessor, providers, modelid))
        }
        else {
            // feature: suppress code generation
            fileSystemAccess.generateFile(fInterface.wampStructsSupportHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp::NO_CODE)
            fileSystemAccess.generateFile(fInterface.wampStructsSupportSourcePath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp::NO_CODE)
        }
    }

    def private generateHeader(FInterface fInterface, PropertyAccessor deploymentAccessor,
        IResource modelid) '''
		«generateCommonApiWampLicenseHeader()»
		#ifndef «fInterface.defineName»_WAMP_STRUCTS_SUPPORT_HPP_
		#define «fInterface.defineName»_WAMP_STRUCTS_SUPPORT_HPP_

		#include <«fInterface.headerPath»>

		«fInterface.generateVersionNamespaceBegin»
		«fInterface.model.generateNamespaceBeginDeclaration»

		«FOR stype : fInterface.types.filter(FStructType)»
			typedef std::tuple<«stype.elements.map[type.genType].join(', ')»> «stype.name»_internal;
			extern «stype.name»_internal transform«stype.name»(const «fInterface.name»::«stype.name» &«stype.name.toFirstLower»);
			extern «fInterface.name»::«stype.name» transform«stype.name»(const «stype.name»_internal &«stype.name.toFirstLower»_internal);
			
		«ENDFOR»
		«fInterface.model.generateNamespaceEndDeclaration»
		«fInterface.generateVersionNamespaceEnd»
		
		#endif // «fInterface.defineName»_WAMP_STRUCTS_SUPPORT_HPP_

    '''

    def private generateSource(FInterface fInterface, PropertyAccessor deploymentAccessor, List<FDProvider> providers,
        IResource modelid) '''
		«generateCommonApiWampLicenseHeader()»

		#include "«fInterface.wampStructsSupportHeaderPath»"

		«fInterface.generateVersionNamespaceBegin»
		«fInterface.model.generateNamespaceBeginDeclaration»

		«FOR stype : fInterface.types.filter(FStructType)»
			«stype.name»_internal transform«stype.name»(const «fInterface.name»::«stype.name» &inst)
			{
				«IF stype.isNested»
				return «stype.name»_internal(
					«FOR elem : stype.elements SEPARATOR ","»
						«IF elem.type.isStruct»
						transform«elem.type.actualDerived.name»(inst.get«elem.name.toFirstUpper»())
						«ELSE»
						inst.get«elem.name.toFirstUpper»()
						«ENDIF»
					«ENDFOR»
				);
				«ELSE»
				return inst.values_;
				«ENDIF»
			}
			
			«fInterface.name»::«stype.name» transform«stype.name»(const «stype.name»_internal &inst_internal)
			{
				«IF stype.isNested»
				return «fInterface.name»::«stype.name»_internal(
					«FOR elem : stype.elements SEPARATOR ","»
						«IF elem.type.isStruct»
						transform«elem.type.actualDerived.name»(std::get<«stype.elements.indexOf(elem)»>(inst_internal))
						«ELSE»
						std::get<«stype.elements.indexOf(elem)»>(inst_internal)
						«ENDIF»
					«ENDFOR»
				);
				«ELSE»
				// TODO: Check if it is ok to return a struct on the stack. 
				«fInterface.name»::«stype.name» inst;
				inst.values_ = inst_internal;
				return inst;
				«ENDIF»
			}

		«ENDFOR»

		«fInterface.model.generateNamespaceEndDeclaration»
		«fInterface.generateVersionNamespaceEnd»
    '''

	def private isNested(FStructType type) {
		type.elements.findFirst[it.type.isStruct]!=null
	}
	
    def private wampStructsSupportHeaderFile(FInterface fInterface) {
        fInterface.elementName + "WampStructsSupport.hpp"
    }

    def public wampStructsSupportHeaderPath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampStructsSupportHeaderFile
    }

    def private wampStructsSupportSourceFile(FInterface fInterface) {
        fInterface.elementName + "WampStructsSupport.cpp"
    }

    def private wampStructsSupportSourcePath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampStructsSupportSourceFile
    }

}
