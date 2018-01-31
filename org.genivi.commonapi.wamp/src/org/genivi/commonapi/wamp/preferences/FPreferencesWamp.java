package org.genivi.commonapi.wamp.preferences;

import java.util.HashMap;
import java.util.Map;
import java.io.File;

import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.franca.core.franca.FModel;
import org.genivi.commonapi.core.preferences.PreferenceConstants;
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp;

public class FPreferencesWamp {

	private static FPreferencesWamp instance = null;
	private Map<String, String> preferences = null;

	public Map<String, String> getPreferences() {
		return preferences;
	}

	private FPreferencesWamp() {
		preferences = new HashMap<String, String>();
		initPreferences();
	}

	public void resetPreferences() {
		preferences.clear();
	}

	public static FPreferencesWamp getInstance() {
		if (instance == null) {
			instance = new FPreferencesWamp();
		}
		return instance;
	}

	private void initPreferences() {
		// -dc,--dest-common <arg> "The directory for the common code"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
		}
		// -dp,--dest-proxy <arg> "The directory for proxy code"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
		}
		// -ds,--dest-stub <arg> "The directory for stub code"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
		}
		// -d,--dest <arg> "The default output directory"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_DEFAULT_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_DEFAULT_WAMP, PreferenceConstants.DEFAULT_OUTPUT);
		}
		// -dsub,--dest-subdirs "Use subdir per interface"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_SUBDIRS_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_SUBDIRS_WAMP, "false");
		}
		// -l,--license <arg> "The file path to the license text that will be added to
		// each generated file"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_LICENSE_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_LICENSE_WAMP, PreferenceConstantsWamp.DEFAULT_LICENSE);
		}
		// -nc,--no-common "Switch off generation of common code"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP, "true");
		}
		// -ns,--no-stub "Switch off generation of stub code"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP, "true");
		}
		// -np,--no-proxy "Switch off generation of proxy code"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP, "true");
		}
		// Franca: -v / CommonAPI: -ll,--loglevel <arg> "The log level (quiet or
		// verbose)"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_LOGOUTPUT_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_LOGOUTPUT_WAMP, "true");
		}
		// -ng,--no-gen "Switch off code generation"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_CODE_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_CODE_WAMP, "true");
		}
		// -wod,--without-dependencies "Switch off code generation of dependencies"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP, "true");
		}
		// -nsc,--no-sync-calls "Switch off code generation of synchronous methods"
		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP, "true");
		}
	}

	public String getPreference(String preferencename, String defaultValue) {

		if (preferences.containsKey(preferencename)) {
			return preferences.get(preferencename);
		}
		System.err.println("Unknown preference " + preferencename);
		return "";
	}

	public void setPreference(String name, String value) {
		if (preferences != null) {
			preferences.put(name, value);
		}
	}

	public String getModelPath(FModel model) {
		String ret = model.eResource().getURI().toString();
		return ret;
	}

	/**
	 * Set the output path configurations (based on stored the preference values)
	 * for file system access types (instance of AbstractFileSystemAccess)
	 * 
	 * @return
	 */
	public HashMap<String, OutputConfiguration> getOutputpathConfiguration() {
		return getOutputpathConfiguration(null);
	}

	/**
	 * Set the output path configurations (based on stored the preference values)
	 * for file system access types (instance of AbstractFileSystemAccess)
	 * 
	 * @subdir the subdir to use, can be null
	 * @return
	 */
	public HashMap<String, OutputConfiguration> getOutputpathConfiguration(String subdir) {

		String defaultDir = getPreference(PreferenceConstantsWamp.P_OUTPUT_DEFAULT_WAMP,
				PreferenceConstants.DEFAULT_OUTPUT);
		String commonDir = getPreference(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, defaultDir);
		String outputProxyDir = getPreference(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, defaultDir);
		String outputStubDir = getPreference(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, defaultDir);

		if (null != subdir && getPreference(PreferenceConstants.P_OUTPUT_SUBDIRS, "false").equals("true")) {
			defaultDir = new File(defaultDir, subdir).getPath();
			commonDir = new File(commonDir, subdir).getPath();
			outputProxyDir = new File(outputProxyDir, subdir).getPath();
			outputStubDir = new File(outputStubDir, subdir).getPath();
		}

		HashMap<String, OutputConfiguration> outputs = new HashMap<String, OutputConfiguration>();

		OutputConfiguration commonOutput = new OutputConfiguration(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP);
		commonOutput.setDescription("Common Output Folder");
		commonOutput.setOutputDirectory(commonDir);
		commonOutput.setCreateOutputDirectory(true);
		outputs.put(IFileSystemAccess.DEFAULT_OUTPUT, commonOutput);

		OutputConfiguration proxyOutput = new OutputConfiguration(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP);
		proxyOutput.setDescription("Proxy Output Folder");
		proxyOutput.setOutputDirectory(outputProxyDir);
		proxyOutput.setCreateOutputDirectory(true);
		outputs.put(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, proxyOutput);

		OutputConfiguration stubOutput = new OutputConfiguration(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP);
		stubOutput.setDescription("Stub Output Folder");
		stubOutput.setOutputDirectory(outputStubDir);
		stubOutput.setCreateOutputDirectory(true);
		outputs.put(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, stubOutput);

		return outputs;
	}

}
