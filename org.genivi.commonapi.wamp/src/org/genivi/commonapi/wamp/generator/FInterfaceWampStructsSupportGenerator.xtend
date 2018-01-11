package org.genivi.commonapi.wamp.generator

import com.google.inject.Inject
import java.util.Collection
import java.util.HashSet
import java.util.List
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.genivi.commonapi.core.generator.FTypeGenerator
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp

class FInterfaceWampStructsSupportGenerator {
    @Inject private extension FTypeGenerator
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaWampGeneratorExtensions

    def generateWampStructsSupport(FTypeCollection fTypeCollection, IFileSystemAccess fileSystemAccess,
        PropertyAccessor deploymentAccessor, List<FDProvider> providers, IResource modelid) {

        if(FPreferencesWamp::getInstance.getPreference(PreferenceConstantsWamp::P_GENERATE_CODE_WAMP, "true").equals("true")) {
            fileSystemAccess.generateFile(fTypeCollection.wampStructsSupportHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP,
                fTypeCollection.generateHeader(deploymentAccessor, modelid))
        }
        else {
            // feature: suppress code generation
            fileSystemAccess.generateFile(fTypeCollection.wampStructsSupportHeaderPath, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp::NO_CODE)
        }
    }

    def private generateHeader(FTypeCollection fTypeCollection, PropertyAccessor deploymentAccessor,
        IResource modelid) '''
		«generateCommonApiWampLicenseHeader()»
		#ifndef «fTypeCollection.defineName»_WAMP_STRUCTS_SUPPORT_HPP_
		#define «fTypeCollection.defineName»_WAMP_STRUCTS_SUPPORT_HPP_

		«val libraryHeaders = new HashSet<String>»
		«val generatedHeaders = new HashSet<String>»
		«fTypeCollection.getRequiredHeaderFiles(generatedHeaders, libraryHeaders)»

		#include <«fTypeCollection.headerPath»>
		«FOR requiredHeaderFile : generatedHeaders.sort»
			#include <«requiredHeaderFile.replace(".hpp", "WampStructsSupport.hpp")»>
		«ENDFOR»

		#include <msgpack.hpp>

		namespace msgpack {
		MSGPACK_API_VERSION_NAMESPACE(MSGPACK_DEFAULT_API_NS) {
		namespace adaptor {

		«FOR etype : fTypeCollection.types.filter(FEnumerationType)»
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
		«FOR stype : fTypeCollection.types.filter(FStructType)»
		template<>
		struct convert<«stype.fullyQualifiedCppName»> {
			msgpack::object const& operator()(msgpack::object const& o, «stype.fullyQualifiedCppName»& v) const {
				if (o.type != msgpack::type::ARRAY) throw msgpack::type_error();
				if (o.via.array.size != «stype.elements.size») throw msgpack::type_error();
				v = «stype.fullyQualifiedCppName» (
					«FOR elem : stype.elements SEPARATOR ','»
						o.via.array.ptr[«stype.elements.indexOf(elem)»].as<«elem.getTypeName(fTypeCollection, true)»>()
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
		«FOR stype : fTypeCollection.types.filter(FUnionType)»
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

		#endif // «fTypeCollection.defineName»_WAMP_STRUCTS_SUPPORT_HPP_

    '''

    def private wampStructsSupportHeaderFile(FTypeCollection fTypeCollection) {
        fTypeCollection.elementName + "WampStructsSupport.hpp"
    }

    def public wampStructsSupportHeaderPath(FTypeCollection fTypeCollection) {
        fTypeCollection.versionPathPrefix + fTypeCollection.model.directoryPath + '/' + fTypeCollection.wampStructsSupportHeaderFile
    }

    def private void getRequiredHeaderFiles(FTypeCollection fTypeCollection, Collection<String> generatedHeaders, Collection<String> libraryHeaders) {
        fTypeCollection.types.forEach[addRequiredHeaders(generatedHeaders, libraryHeaders)]
        generatedHeaders.remove(fTypeCollection.headerPath)
    }

}
