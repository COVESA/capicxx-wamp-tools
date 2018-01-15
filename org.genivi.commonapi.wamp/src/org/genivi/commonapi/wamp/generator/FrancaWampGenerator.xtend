package org.genivi.commonapi.wamp.generator

import java.io.File
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.Map
import java.util.Set
import javax.inject.Inject
import org.eclipse.core.resources.IResource
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeCollection
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.genivi.commonapi.core.generator.FDeployManager
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.wamp.deployment.PropertyAccessor
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp

class FrancaWampGenerator implements IGenerator {
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaWampGeneratorExtensions
    @Inject private extension FInterfaceWampProxyGenerator
    @Inject private extension FInterfaceWampStubAdapterGenerator
    @Inject private extension FInterfaceWampTypesSupportGenerator
    @Inject private extension FInterfaceWampDeploymentGenerator

    @Inject private FrancaPersistenceManager francaPersistenceManager
    @Inject private FDeployManager fDeployManager

    override doGenerate(Resource input, IFileSystemAccess fileSystemAccess) {
        if (!input.URI.fileExtension.equals(francaPersistenceManager.fileExtension) &&
            !input.URI.fileExtension.equals(FDeployManager.fileExtension)) {
                return
        }

        var List<FDInterface> deployedInterfaces = new LinkedList<FDInterface>()
        var List<FDTypes> deployedTypeCollections = new LinkedList<FDTypes>()
        var List<FDProvider> deployedProviders = new LinkedList<FDProvider>()

        var IResource res = null

        val String CORE_SPECIFICATION_TYPE = "core.deployment"
        val String WAMP_SPECIFICATION_TYPE = "wamp.deployment"

        val String CORE_SPECIFICATION_NAME = "org.genivi.commonapi.core.deployment"
        val String WAMP_SPECIFICATION_NAME = "org.genivi.commonapi.wamp.deployment"

        var rootModel = fDeployManager.loadModel(input.URI, input.URI)

        generatedFiles_ = new HashSet<String>()

        withDependencies_ = FPreferencesWamp::instance.getPreference(
            PreferenceConstantsWamp::P_GENERATE_DEPENDENCIES_WAMP, "true"
        ).equals("true")

        var models = fDeployManager.fidlModels
        var deployments = fDeployManager.deploymentModels

        if (rootModel instanceof FDModel) {
            deployments.put(input.URI.toString, rootModel)
        } else if (rootModel instanceof FModel) {
            models.put(input.URI.toString, rootModel)
        }

        var allCoreInterfaces = new LinkedList<FDInterface>()
        var allCoreTypeCollections = new LinkedList<FDTypes>()
        for (itsEntry : deployments.entrySet) {
            val itsDeployment = itsEntry.value

            // Get Core deployments
            val itsCoreInterfaces = getFDInterfaces(itsDeployment, CORE_SPECIFICATION_TYPE)
            val itsCoreTypeCollections = getFDTypesList(itsDeployment, CORE_SPECIFICATION_TYPE)
            
            allCoreInterfaces.addAll(itsCoreInterfaces)
            allCoreTypeCollections.addAll(itsCoreTypeCollections)
        }

        // Check whether there do exist models without deployment. If yes, create deployment for them.
        var missingCoreInterfaces = new LinkedList<FDInterface>()
        var missingCoreTypeCollections = new LinkedList<FDTypes>()
        val itsCoreSpecification = fDeployManager.getDeploymentSpecification(CORE_SPECIFICATION_NAME)
        if (itsCoreSpecification != null) {
            for (itsEntry : models.entrySet) {
                val itsModel = itsEntry.value
 
                if (itsModel != null) {
                    for (i : itsModel.interfaces) {
                        if (!i.isDeployed(allCoreInterfaces)) {
                            val itsNewDeployment = FDeployFactory.eINSTANCE.createFDInterface()
                            itsNewDeployment.target = i
                            itsNewDeployment.spec = itsCoreSpecification
                        
                            missingCoreInterfaces.add(itsNewDeployment)
                        }
                    }

                    for (i : itsModel.typeCollections) {
                        if (!i.isDeployed(allCoreTypeCollections)) {
                            val itsNewDeployment = FDeployFactory.eINSTANCE.createFDTypes()
                            itsNewDeployment.target = i
                            itsNewDeployment.spec = itsCoreSpecification
                        
                            missingCoreTypeCollections.add(itsNewDeployment)
                        }
                    }
                }
            }
        }

        allCoreInterfaces.addAll(missingCoreInterfaces)
        allCoreTypeCollections.addAll(missingCoreTypeCollections)
        
        // Finally check/create/merge the Wamp deployment
        var itsWampSpecification = fDeployManager.getDeploymentSpecification(WAMP_SPECIFICATION_NAME)
        if (itsWampSpecification == null)
            itsWampSpecification = fDeployManager.getDeploymentSpecification(CORE_SPECIFICATION_NAME)
        if (itsWampSpecification != null) {
            for (itsEntry : deployments.entrySet) {
                val itsDeployment = itsEntry.value
    
                // Get Wamp deployments
                val itsWampInterfaces = getFDInterfaces(itsDeployment, WAMP_SPECIFICATION_TYPE)
                val itsWampTypeCollections = getFDTypesList(itsDeployment, WAMP_SPECIFICATION_TYPE)
                val itsWampProviders = getFDProviders(itsDeployment, WAMP_SPECIFICATION_TYPE)
    
                // Create Wamp deployments for interfaces/type collections without
                if (rootModel instanceof FDModel) {
                    for (m : models.entrySet) {
                        for (i : m.value.interfaces) {
                            if (!i.isDeployed(itsWampInterfaces) && !i.isDeployed(deployedInterfaces)) {
                                val itsNewDeployment = FDeployFactory.eINSTANCE.createFDInterface()
                                itsNewDeployment.target = i
                                itsNewDeployment.spec = itsWampSpecification
                                
                                rootModel.deployments.add(itsNewDeployment)
                                itsWampInterfaces.add(itsNewDeployment)
                            }
                        }
                        for (i : m.value.typeCollections) {
                            if (!i.isDeployed(itsWampTypeCollections) && !i.isDeployed(deployedTypeCollections)) {
                                val itsNewDeployment = FDeployFactory.eINSTANCE.createFDTypes()
                                itsNewDeployment.target = i
                                itsNewDeployment.spec = itsWampSpecification
                                
                                rootModel.deployments.add(itsNewDeployment)
                                itsWampTypeCollections.add(itsNewDeployment)
                            }
                        }
                    }
                }
                
                // Merge Core deployments for interfaces to their Wamp deployments
                for (itsWampDeployment : itsWampInterfaces) {
                    for (itsCoreDeployment : allCoreInterfaces)
                        mergeDeployments(itsCoreDeployment, itsWampDeployment)
                    for (itsCoreDeployment : allCoreTypeCollections)
                        mergeDeployments(itsCoreDeployment, itsWampDeployment)
                }
                
                // Merge Core deployments for type collections to their Wamp deployments
                for (itsWampDeployment : itsWampTypeCollections)
                    for (itsCoreDeployment : allCoreTypeCollections)
                        mergeDeploymentsExt(itsCoreDeployment, itsWampDeployment)
    
                deployedInterfaces.addAll(itsWampInterfaces)
                deployedTypeCollections.addAll(itsWampTypeCollections)
                deployedProviders.addAll(itsWampProviders)
            }
        }

        if (rootModel instanceof FDModel) {
            doGenerateDeployment(rootModel, deployments, models,
                deployedInterfaces, deployedTypeCollections, deployedProviders,
                fileSystemAccess, res, true)
        } else if (rootModel instanceof FModel) {
            doGenerateModel(rootModel, models,
                deployedInterfaces, deployedTypeCollections, deployedProviders,
                fileSystemAccess, res)
        }

        fDeployManager.clearFidlModels
        fDeployManager.clearDeploymentModels
    }

    def private boolean isDeployed(FInterface _iface, List<FDInterface> _deployments) {
        for (d : _deployments) {
            if (d.target == _iface) {
                return true
            }
        }
        return false
    }

    def private boolean isDeployed(FTypeCollection _tc, List<FDTypes> _deployments) {
        for (d : _deployments) {
            if (d.target == _tc) {
                return true
            }
        }
        return false
    }

    def private void doGenerateDeployment(FDModel _deployment,
                                          Map<String, FDModel> _deployments,
                                          Map<String, FModel> _models,
                                          List<FDInterface> _interfaces,
                                          List<FDTypes> _typeCollections,
                                          List<FDProvider> _providers,
                                          IFileSystemAccess _access,
                                          IResource _res,
                                          boolean _mustGenerate) {
        val String deploymentName
            = _deployments.entrySet.filter[it.value == _deployment].head.key

        var int lastIndex = deploymentName.lastIndexOf(File.separatorChar)
        if (lastIndex == -1) {
            lastIndex = deploymentName.lastIndexOf('/')
        }

        var String basePath = deploymentName.substring(
            0, lastIndex)

        var Set<String> itsImports = new HashSet<String>()
        for (anImport : _deployment.imports) {
            val String cannonical = basePath.getCanonical(anImport.importURI)
            itsImports.add(cannonical)
        }

        for (itsEntry : _models.entrySet) {
            if (itsImports.contains(itsEntry.key)) {
                doInsertAccessors(itsEntry.value, _interfaces, _typeCollections)
            }
        }

        for (itsEntry : _deployments.entrySet) {
            if (itsImports.contains(itsEntry.key)) {
                doGenerateDeployment(itsEntry.value, _deployments, _models,
                    _interfaces, _typeCollections, _providers,
                    _access, _res, withDependencies_)
            }
        }

        if (_mustGenerate) {
            for (itsEntry : _models.entrySet) {
                if (itsImports.contains(itsEntry.key)) {

                    doGenerateModel(itsEntry.value, _models,
                        _interfaces, _typeCollections, _providers,
                        _access, _res)
                }
            }
        }
    }

    def private void doGenerateModel(FModel _model,
                                     Map<String, FModel> _models,
                                     List<FDInterface> _interfaces,
                                     List<FDTypes> _typeCollections,
                                     List<FDProvider> _providers,
                                     IFileSystemAccess _access,
                                     IResource _res) {
        val String modelName
            = _models.entrySet.filter[it.value == _model].head.key

        if (generatedFiles_.contains(modelName)) {
            return
        }

        generatedFiles_.add(modelName)

        doGenerateComponents(_model,
            _interfaces, _typeCollections, _providers,
            _access, _res)

        if (withDependencies_) {
            for (itsEntry : _models.entrySet) {
                var FModel itsModel = itsEntry.value
                if (itsModel != null) {
                    doGenerateComponents(itsModel,
                        _interfaces, _typeCollections, _providers,
                        _access, _res)
                }
            }
        }
    }

    def private doInsertAccessors(FModel _model,
                                  List<FDInterface> _interfaces,
                                  List<FDTypes> _typeCollections) {
        val defaultDeploymentAccessor = new PropertyAccessor()

        _model.typeCollections.forEach [
            var PropertyAccessor typeCollectionDeploymentAccessor
            val currentTypeCollection = it
            if (_typeCollections.exists[it.target == currentTypeCollection]) {
                typeCollectionDeploymentAccessor = new PropertyAccessor(
                    new FDeployedTypeCollection(_typeCollections.filter[it.target == currentTypeCollection].last))
            } else {
                typeCollectionDeploymentAccessor = defaultDeploymentAccessor
            }
            insertAccessor(currentTypeCollection, typeCollectionDeploymentAccessor)
        ]

        _model.interfaces.forEach [
            var PropertyAccessor interfaceDeploymentAccessor
            val currentInterface = it
            if (_interfaces.exists[it.target == currentInterface]) {
                interfaceDeploymentAccessor = new PropertyAccessor(
                    new FDeployedInterface(_interfaces.filter[it.target == currentInterface].last))
            } else {
                interfaceDeploymentAccessor = defaultDeploymentAccessor
            }
            insertAccessor(currentInterface, interfaceDeploymentAccessor)
        ]
    }

    def private void doGenerateComponents(FModel _model,
                                     List<FDInterface> _interfaces,
                                     List<FDTypes> _typeCollections,
                                     List<FDProvider> _providers,
                                     IFileSystemAccess _access,
                                     IResource _res) {
        var interfacesToGenerate = _model.interfaces.toSet
        var typeCollectionsToGenerate = _model.typeCollections.toSet

        typeCollectionsToGenerate.forEach [
        	val pa = getAccessor(it)
            it.generateTypeCollectionDeployment(_access, pa, _res)
            it.generateWampTypesSupport(_access, pa, _providers, _res)
        ]

        interfacesToGenerate.forEach [
            val currentInterface = it
            var PropertyAccessor deploymentAccessor = getAccessor(it);
            if (null == deploymentAccessor) {
	            if (_interfaces.exists[it.target == currentInterface]) {
	                deploymentAccessor = new PropertyAccessor(
	                    new FDeployedInterface(_interfaces.filter[it.target == currentInterface].last))
	            } else {
	                deploymentAccessor = new PropertyAccessor()
	            }
			}
//            if (FPreferencesWamp::instance.getPreference(PreferenceConstantsWamp::P_GENERATE_PROXY_WAMP, "true").
//                equals("true")) {
//                it.generateWampProxy(_access, deploymentAccessor, _providers, _res)
//            }
            if (FPreferencesWamp::instance.getPreference(PreferenceConstantsWamp::P_GENERATE_STUB_WAMP, "true").
                equals("true")) {
                it.generateWampStubAdapter(_access, deploymentAccessor, _providers, _res)
                it.generateWampTypesSupport(_access, deploymentAccessor, _providers, _res)
            }

            if (FPreferencesWamp::instance.getPreference(PreferenceConstantsWamp::P_GENERATE_COMMON_WAMP, "true").
                equals("true")) {
                it.generateDeployment(_access, deploymentAccessor, _res)
            }
            it.managedInterfaces.forEach [
                val currentManagedInterface = it
                var PropertyAccessor managedDeploymentAccessor
                if (_interfaces.exists[it.target == currentManagedInterface]) {
                    managedDeploymentAccessor = new PropertyAccessor(
                        new FDeployedInterface(_interfaces.filter[it.target == currentManagedInterface].last))
                } else {
                    managedDeploymentAccessor = new PropertyAccessor()
                }

                if (FPreferencesWamp::instance.getPreference(PreferenceConstantsWamp::P_GENERATE_PROXY_WAMP, "true").
                    equals("true")) {
                    it.generateWampProxy(_access, managedDeploymentAccessor, _providers, _res)
                }
                if (FPreferencesWamp::instance.getPreference(PreferenceConstantsWamp::P_GENERATE_STUB_WAMP, "true").
                    equals("true")) {
                    it.generateWampStubAdapter(_access, managedDeploymentAccessor, _providers, _res)
                    it.generateWampTypesSupport(_access, managedDeploymentAccessor, _providers, _res)
                }
            ]
        ]
    }

    private boolean withDependencies_
    private Set<String> generatedFiles_
}
