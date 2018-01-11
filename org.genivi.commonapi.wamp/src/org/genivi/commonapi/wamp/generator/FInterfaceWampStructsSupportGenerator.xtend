package org.genivi.commonapi.wamp.generator

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStructType
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp

class FInterfaceWampStructsSupportGenerator {
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaWampGeneratorExtensions
    @Inject private extension FrancaWampTypeExtensions

    def generateWampStructsSupport(FInterface fInterface, IFileSystemAccess fileSystemAccess,
        PropertyAccessor deploymentAccessor, List<FDProvider> providers, IResource modelid) {

        if(FPreferencesWamp::getInstance.getPreference(PreferenceConstantsWamp::P_GENERATE_CODE_WAMP, "true").equals("true")) {
            fileSystemAccess.generateFile(fInterface.wampStructsSupportHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
                fInterface.generateHeader(deploymentAccessor, modelid))
        }
        else {
            // feature: suppress code generation
            fileSystemAccess.generateFile(fInterface.wampStructsSupportHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp::NO_CODE)
        }
    }

    def private generateHeader(FInterface fInterface, PropertyAccessor deploymentAccessor,
        IResource modelid) '''
		«generateCommonApiWampLicenseHeader()»
		#ifndef «fInterface.defineName»_WAMP_STRUCTS_SUPPORT_HPP_
		#define «fInterface.defineName»_WAMP_STRUCTS_SUPPORT_HPP_

		#include <«fInterface.headerPath»>
		#include <msgpack.hpp>

		namespace msgpack {
		MSGPACK_API_VERSION_NAMESPACE(MSGPACK_DEFAULT_API_NS) {
		namespace adaptor {

		«FOR etype : fInterface.types.filter(FEnumerationType)»
		template<>
		struct convert<«etype.fullyQualifiedCppName»> {
			msgpack::object const& operator()(msgpack::object const& o, «etype.fullyQualifiedCppName»& v) const {
				if (o.type != msgpack::type::POSITIVE_INTEGER) throw msgpack::type_error();
				v.value_ = o.as<uint32_t>();
				return o;
			}
		};
		
		template<>
		struct object_with_zone<«etype.fullyQualifiedCppName»> {
			void operator()(msgpack::object::with_zone& o, «etype.fullyQualifiedCppName» const& v) const {
				msgpack::operator<<(o, v.value_);
			}
		};

		«ENDFOR»
		«FOR stype : fInterface.types.filter(FStructType)»
		template<>
		struct convert<«stype.fullyQualifiedCppName»> {
			msgpack::object const& operator()(msgpack::object const& o, «stype.fullyQualifiedCppName»& v) const {
				if (o.type != msgpack::type::ARRAY) throw msgpack::type_error();
				if (o.via.array.size != «stype.elements.size») throw msgpack::type_error();
				v = «stype.fullyQualifiedCppName» (
					«FOR elem : stype.elements SEPARATOR ','»
						o.via.array.ptr[«stype.elements.indexOf(elem)»].as<«elem.getTypename(fInterface)»>()
					«ENDFOR»
		        );
				return o;
			}
		};

		template<>
		struct object_with_zone<«stype.fullyQualifiedCppName»> {
			void operator()(msgpack::object::with_zone& o, «stype.fullyQualifiedCppName» const& v) const {
				o.type = type::ARRAY;
				o.via.array.size = «stype.elements.size»;
				o.via.array.ptr = static_cast<msgpack::object*>(
				o.zone.allocate_align(sizeof(msgpack::object) * o.via.array.size));
				«FOR elem : stype.elements»
					o.via.array.ptr[«stype.elements.indexOf(elem)»] = msgpack::object(v.get«elem.name.toFirstUpper»(), o.zone);
				«ENDFOR»
			}
		};
		
		«ENDFOR»
		«FOR stype : fInterface.types.filter(FUnionType)»
		template<>
		struct convert<«stype.fullyQualifiedCppName»> {
			msgpack::object const& operator()(msgpack::object const& o, «stype.fullyQualifiedCppName»& v) const {
				std::cout << "TODO: adapter for unions not implemented yet (convert)" << std::endl;
				return o;
			}
		};

		template<>
		struct object_with_zone<«stype.fullyQualifiedCppName»> {
			void operator()(msgpack::object::with_zone& o, «stype.fullyQualifiedCppName» const& v) const {
				std::cout << "TODO: adapter for unions not implemented yet (object_with_zone)" << std::endl;
			}
		};
		
		«ENDFOR»
		} // namespace adaptor
		} // MSGPACK_API_VERSION_NAMESPACE(MSGPACK_DEFAULT_API_NS)
		} // namespace msgpack

		#endif // «fInterface.defineName»_WAMP_STRUCTS_SUPPORT_HPP_

    '''

    def private wampStructsSupportHeaderFile(FInterface fInterface) {
        fInterface.elementName + "WampStructsSupport.hpp"
    }

    def public wampStructsSupportHeaderPath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.wampStructsSupportHeaderFile
    }

}
