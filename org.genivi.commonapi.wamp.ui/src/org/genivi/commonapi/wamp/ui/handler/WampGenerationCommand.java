package org.genivi.commonapi.wamp.ui.handler;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.genivi.commonapi.core.ui.handler.GenerationCommand;
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp;
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp;
import org.genivi.commonapi.wamp.ui.CommonApiWampUiPlugin;

public class WampGenerationCommand extends GenerationCommand {

	/**
	 * Init wamp preferences
	 * @param page
	 * @param projects
	 */
	@Override
	protected void setupPreferences(IFile file) {

		initWampPreferences(file, CommonApiWampUiPlugin.getDefault().getPreferenceStore());
	}	

	@Override
	protected EclipseResourceFileSystemAccess2 createFileSystemAccess() {

		final EclipseResourceFileSystemAccess2 fsa = fileAccessProvider.get();

		fsa.setMonitor(new NullProgressMonitor());

		return fsa;
	}

	@Override
	protected void setupOutputDirectories(EclipseResourceFileSystemAccess2 fileSystemAccess) {
		fileSystemAccess.setOutputConfigurations(FPreferencesWamp.getInstance().getOutputpathConfiguration());
	}	
	
	
	/**
	 * Set the properties for the code generation from the resource properties (set with the property page, via the context menu).
	 * Take default values from the eclipse preference page.
	 * @param file 
	 * @param store - the eclipse preference store
	 */
	public void initWampPreferences(IFile file, IPreferenceStore store) {
		FPreferencesWamp instance = FPreferencesWamp.getInstance();

		String outputFolderCommon = null;
		String outputFolderProxies = null;
		String outputFolderStubs = null;
		String licenseHeader = null;
		String generateCommon = null;
		String generateProxy = null;
		String generatStub = null;		
		String generatInclude = null;
		String generatSyncCalls = null;

		IProject project = file.getProject();
		IResource resource = file;
		
		try {
			// Should project or file specific properties be used ?
			String useProject1 = project.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_USEPROJECTSETTINGS));
			String useProject2 = file.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_USEPROJECTSETTINGS));
			if("true".equals(useProject1) || "true".equals(useProject2)) {
				resource = project;
			} 
			outputFolderCommon = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP));
			outputFolderProxies = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP));
			outputFolderStubs = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP));
			licenseHeader = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_LICENSE_WAMP));
			generateCommon = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP));
			generateProxy = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP));
			generatStub = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_GENERATE_STUB_WAMP));
			generatInclude = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP));
			generatSyncCalls = resource.getPersistentProperty(new QualifiedName(PreferenceConstantsWamp.PROJECT_PAGEID, PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP));
		} catch (CoreException e1) {
			System.err.println("Failed to get property for " + resource.getName());
		}
		// Set defaults in the very first case, where nothing was specified from the user.
		if(outputFolderCommon == null) {
			outputFolderCommon = store.getString(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP);			
		}
		if(outputFolderProxies == null) {
			outputFolderProxies = store.getString(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP);			
		}
		if(outputFolderStubs == null) {
			outputFolderStubs = store.getString(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP);	
		}
		if(licenseHeader == null) {
			licenseHeader = store.getString(PreferenceConstantsWamp.P_LICENSE_WAMP);			
		}
		if(generateCommon == null) {
			generateCommon = store.getString(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP);	
		}
		if(generateProxy == null) {
			generateProxy = store.getString(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP);	
		}
		if(generatStub == null) {
			generatStub = store.getString(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP);
		}
		if(generatInclude == null) {
			generatInclude = store.getString(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP);
		}		
		if(generatSyncCalls == null) {
			generatSyncCalls = store.getString(PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP);
		}		
		// finally, store the properties for the code generator
		instance.setPreference(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, outputFolderCommon);
		instance.setPreference(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, outputFolderProxies);
		instance.setPreference(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, outputFolderStubs);
		instance.setPreference(PreferenceConstantsWamp.P_LICENSE_WAMP, licenseHeader);
		instance.setPreference(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP, generateCommon);
		instance.setPreference(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP, generateProxy);
		instance.setPreference(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP, generatStub);
		instance.setPreference(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP, generatInclude);
		instance.setPreference(PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP, generatSyncCalls);
	}   

}
