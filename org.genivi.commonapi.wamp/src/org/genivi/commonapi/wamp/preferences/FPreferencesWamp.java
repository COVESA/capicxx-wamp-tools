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
		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, PreferenceConstantsWamp.DEFAULT_OUTPUT);
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_DEFAULT_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_DEFAULT_WAMP, PreferenceConstants.DEFAULT_OUTPUT);
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_OUTPUT_SUBDIRS_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_OUTPUT_SUBDIRS_WAMP, "false");
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_LICENSE_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_LICENSE_WAMP, PreferenceConstantsWamp.DEFAULT_LICENSE);
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP, "true");
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP, "true");
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP, "true");
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_LOGOUTPUT_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_LOGOUTPUT_WAMP, "true");
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_CODE_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_CODE_WAMP, "true");
		}

		if (!preferences.containsKey(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP)) {
			preferences.put(PreferenceConstantsWamp.P_GENERATE_DEPENDENCIES_WAMP, "true");
		}

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
