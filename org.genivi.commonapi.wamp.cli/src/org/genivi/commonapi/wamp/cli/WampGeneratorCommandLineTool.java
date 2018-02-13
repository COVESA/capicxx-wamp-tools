package org.genivi.commonapi.wamp.cli;

import static org.genivi.commonapi.wamp.cli.FileHelper.createAbsolutPath;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.franca.core.franca.FModel;
import org.genivi.commonapi.wamp.WampGeneratorFrancaStandaloneSetup;
import org.genivi.commonapi.wamp.preferences.FPreferencesWamp;
import org.genivi.commonapi.wamp.preferences.PreferenceConstantsWamp;

import com.google.inject.Inject;

/**
 * Runner for standalone CommonAPI/WAMP generation from Franca files.
 * 
 * @author Klaus Birken (itemis), Markus Mühlbrandt (itemis)
 */
@SuppressWarnings("deprecation")
public class WampGeneratorCommandLineTool extends AbstractCommandLineTool implements WampGeneratorOptions {

	private static final String CLI_TOOL_NAME = "Wamp Generator CLI Tool";
	private static final String TOOL_VERSION = "0.7.0";
	private static final Logger logger = Logger.getLogger(CLI_TOOL_NAME);
	private boolean logInfo = true;
	private boolean logError = true;

	/**
	 * The main function for this standalone tool.
	 * </p>
	 * 
	 * It directly hands over control to the CommandLineTool framework.
	 * 
	 * @param args
	 *            the collection of command line arguments
	 */
	public static void main(String[] args) {
		// hand over control to CommandLineTool framework
		execute(new WampGeneratorFrancaStandaloneSetup(), TOOL_VERSION, WampGeneratorCommandLineTool.class, args);
	}

	// injected fragments
	@Inject
	IGenerator generator;

	@Override
	protected int run(CommandLine line) {

		if (line.hasOption(OPT_LOG_LEVEL)) {
			setLogLevel(line.getOptionValue(OPT_LOG_LEVEL));
		}

		if (line.hasOption(CommonOptions.VERBOSE)) {
			setLogLevel(PreferenceConstantsWamp.LOGLEVEL_VERBOSE);
		}

		// load Franca IDL file
		String fidlFile = line.getOptionValue(OPT_FIDL_FILE);
		FModel fmodel = persistenceManager.loadModel(fidlFile);
		if (fmodel == null) {
			logError("Couldn't load Franca IDL file '" + fidlFile + "'.");
			return -1;
		}

		// call validator
		int nErrors = validateModel(fmodel, line.hasOption(OPT_RECURSIVE_VALIDATION));
		if (nErrors > 0) {
			logError("Validation of Franca model: " + nErrors + " errors, aborting.");
			return -1;
		}

		if (line.hasOption(OPT_OUTDIR)) {
			setDefaultDirectory(line.getOptionValue(OPT_OUTDIR));
		}

		if (line.hasOption(OPT_OUTDIR_COMMON)) {
			setCommonDirectory(line.getOptionValue(OPT_OUTDIR_COMMON));
		}

		if (line.hasOption(OPT_OUTDIR_PROXY)) {
			setProxyDirectory(line.getOptionValue(OPT_OUTDIR_PROXY));
		}

		if (line.hasOption(OPT_OUTDIR_STUB)) {
			setStubDirectory(line.getOptionValue(OPT_OUTDIR_STUB));
		}

		if (line.hasOption(OPT_OUTDIR_SUB)) {
			enableDestinationSubdirs();
		}

		if (line.hasOption(OPT_NO_CODE)) {
			disableCodeGeneration();
		}

		if (line.hasOption(OPT_NO_COMMON)) {
			disableCommonCode();
		}

		if (line.hasOption(OPT_NO_PROXY)) {
			disableProxyCode();
		}

		if (line.hasOption(OPT_NO_STUB)) {
			disableStubCode();
		}

		if (line.hasOption(OPT_NO_SYNC_CALLS)) {
			disableSyncCalls();
		}

		if (line.hasOption(OPT_LICENSE)) {
			setLicenseText(line.getOptionValue(OPT_LICENSE));
		}

		// call generator and save files
		JavaIoFileSystemAccess fsa = injector.getInstance(JavaIoFileSystemAccess.class);
		fsa.setOutputConfigurations(getPreferences().getOutputpathConfiguration());
		logInfo("Generating '%s'.", fidlFile);
		generator.doGenerate(fmodel.eResource(), fsa);
		logInfo("'%s' generation finished.", fidlFile);
		return 0;
	}

	@Override
	protected void addOptions(Options options) {
		options.addOption(createFileOption());
		options.addOption(createOutDirOption());
		options.addOption(createOutDirCommonOption());
		options.addOption(createOutDirProxyOption());
		options.addOption(createOutDirStubOption());
		options.addOption(createLicenseOption());
		options.addOption(createLogLevelOption());
		options.addOption(createOutputSubDirOption());
		options.addOption(createRecursiveValidationOption());
		options.addOption(createNoCodeOption());
		options.addOption(createNoCommonOption());
		options.addOption(createNoProxyOption());
		options.addOption(createNoStubOption());
		options.addOption(createNoSyncCallsOption());
	}

	@Override
	protected boolean checkCommandLineValues(CommandLine line) {
		if (line.hasOption(OPT_FIDL_FILE)) {
			String fidlFile = line.getOptionValue(OPT_FIDL_FILE);
			File fidl = new File(fidlFile);
			if (!fidl.exists()) {
				logError("Cannot open Franca IDL file '%s'.", fidlFile);
				return false;
			}
		}

		if (line.hasOption(OPT_LOG_LEVEL)) {
			String logLevel = line.getOptionValue(OPT_LOG_LEVEL);

			if (!LOG_LEVEL_VALUE_QUIET.equalsIgnoreCase(logLevel)
					&& !LOG_LEVEL_VALUE_VERBOSE.equalsIgnoreCase(logLevel)) {
				logError("Invalid argument '%s' for option '-ll'.", logLevel);
				return false;
			}

			if (line.hasOption(CommonOptions.VERBOSE) && LOG_LEVEL_VALUE_QUIET.equalsIgnoreCase(logLevel)) {
				logError("Option '-ll quiet' in combination with option '-v' is invalid.");
				return false;
			}
		}

		if (line.hasOption(OPT_LICENSE)) {

			File file = new File(createAbsolutPath(line.getOptionValue(OPT_LICENSE)));
			if (!file.exists() || file.isDirectory()) {
				logError("Please specify a path to an existing file after option '-l'.");
				return false;
			}

		}
		return true;
	}

	private FPreferencesWamp getPreferences() {
		return FPreferencesWamp.getInstance();
	}

	@Override
	protected void logError(String message) {
		if (logError) {
			logger.error(message);
		}
	}

	protected void logError(String message, Object... args) {
		logError(String.format(message, args));
	}

	@Override
	protected void logInfo(String message) {
		if (logInfo) {
			logger.info(message);
		}
	}

	protected void logInfo(String message, Object... args) {
		logInfo(String.format(message, args));
	}

	private void setCommonDirectory(String optionValue) {
		logInfo("Common output directory: " + optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, optionValue);
	}

	private void setDefaultDirectory(String optionValue) {
		logInfo("Default output directory: " + optionValue);

		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_DEFAULT_WAMP, optionValue);
		// In the case where no other output directories are set,
		// this default directory will be used for them
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, optionValue);
	}

	private void enableDestinationSubdirs() {
		logInfo("Using destination subdirs");
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_SUBDIRS_WAMP, "true");
	}

	private void setLogLevel(String optionValue) {
		if (PreferenceConstantsWamp.LOGLEVEL_QUIET.equals(optionValue)) {
			getPreferences().setPreference(PreferenceConstantsWamp.P_LOGOUTPUT_WAMP, "false");
			logInfo = false;
			logError = false;
		}
		if (PreferenceConstantsWamp.LOGLEVEL_VERBOSE.equals(optionValue)) {
			getPreferences().setPreference(PreferenceConstantsWamp.P_LOGOUTPUT_WAMP, "true");
			logInfo = true;
			logError = true;
		}
	}

	private void setProxyDirectory(String optionValue) {
		logInfo("Proxy output directory: " + optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, optionValue);
	}

	private void setStubDirectory(String optionValue) {
		logInfo("Stub output directory: " + optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, optionValue);
	}

	private void disableCommonCode() {
		logInfo("Generation of common code disabled");
		getPreferences().setPreference(PreferenceConstantsWamp.P_GENERATE_COMMON_WAMP, "false");
	}

	private void disableStubCode() {
		logInfo("Generation of stub code disabled");
		getPreferences().setPreference(PreferenceConstantsWamp.P_GENERATE_STUB_WAMP, "false");
	}

	private void disableProxyCode() {
		logInfo("Generation of proxy code disabled");
		getPreferences().setPreference(PreferenceConstantsWamp.P_GENERATE_PROXY_WAMP, "false");
	}

	private void disableCodeGeneration() {
		logInfo("Code generation disabled");
		getPreferences().setPreference(PreferenceConstantsWamp.P_GENERATE_CODE_WAMP, "false");
	}

	private void disableSyncCalls() {
		logInfo("Generation of synchronous methods disabled");
		getPreferences().setPreference(PreferenceConstantsWamp.P_GENERATE_SYNC_CALLS_WAMP, "false");
	}

	private void setLicenseText(String fileWithText) {

		String licenseText = getLicenseText(fileWithText);

		if (licenseText != null && !licenseText.isEmpty()) {
			getPreferences().setPreference(PreferenceConstantsWamp.P_LICENSE_WAMP, licenseText);
		}
	}

	public String getLicenseText(String fileWithText) {
		String licenseText = "";

		// Check for valid file string is done in checkCommandLineValues...
		File file = new File(createAbsolutPath(fileWithText));

		BufferedReader inReader = null;

		try {
			inReader = new BufferedReader(new FileReader(file));
			String thisLine;
			while ((thisLine = inReader.readLine()) != null) {
				licenseText = licenseText + thisLine + "\n";
			}
		} catch (IOException e) {
			logError("Failed to get the text from the given file: %s", e.getLocalizedMessage());
		} finally {
			try {
				if (inReader != null) {
					inReader.close();
				}
			} catch (Exception e) {
				logError("Failed to close buffered reader: %s", e.getLocalizedMessage());
			}
		}

		return licenseText;
	}

}
