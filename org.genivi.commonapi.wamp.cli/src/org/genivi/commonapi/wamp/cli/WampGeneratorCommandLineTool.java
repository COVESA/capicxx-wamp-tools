package org.genivi.commonapi.wamp.cli;

import java.io.File;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
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
public class WampGeneratorCommandLineTool extends AbstractCommandLineTool {
	
	private static final String TOOL_VERSION = "0.7.0";

	// specific option values
	private static final String FIDLFILE = "f";
	private static final String OPT_RECURSIVE_VALIDATION = "r";
	private static final String OPT_RECURSIVE_VALIDATION_LONG = "recursive-validation";
	private static final String OPT_LOG_LEVEL = "ll";
	private static final String OPT_LOG_LEVEL_LONG = "loglevel";
	private static final String OPT_OUTDIR = "d";
	private static final String OPT_OUTDIR_LONG = "dest";

	// prepare class for logging....
	private static final Logger logger = Logger.getLogger(WampGeneratorCommandLineTool.class);
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
		// print version string
		// System.out.println(TOOL_VERSION);

		if (line.hasOption(OPT_LOG_LEVEL)) {
			setLogLevel(line.getOptionValue(OPT_LOG_LEVEL));
		}
		
		if (line.hasOption(CommonOptions.VERBOSE)) {
			setLogLevel(PreferenceConstantsWamp.LOGLEVEL_VERBOSE);
		}

		// load Franca IDL file
		String fidlFile = line.getOptionValue(FIDLFILE);
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

		FPreferencesWamp preferences = FPreferencesWamp.getInstance();
		if (line.hasOption(OPT_OUTDIR)) {
			setDefaultDirectory(line.getOptionValue(OPT_OUTDIR));
		}

		// call generator and save files
		JavaIoFileSystemAccess fsa = injector.getInstance(JavaIoFileSystemAccess.class);
		fsa.setOutputConfigurations(preferences.getOutputpathConfiguration());
		logInfo(String.format("Generating \"%s\".", fidlFile));
		generator.doGenerate(fmodel.eResource(), fsa);
		logInfo(String.format("\"%s\" generation finished.", fidlFile));
		return 0;
	}

	@Override
	protected void addOptions(Options options) {
		// required
		options.addOption(createFileOption());

		// option for configuration of an output directory
		options.addOption(createOutputDirOption());

		options.addOption(createLogLevelOption());

		options.addOption(createRecursiveValidationOption());
	}

	@SuppressWarnings("static-access")
	private Option createRecursiveValidationOption() {
		return OptionBuilder//
				.withArgName("recval")//
				.withDescription("Recursive validation")//
				.hasArg(false)//
				.isRequired(false)//
				.withLongOpt(OPT_RECURSIVE_VALIDATION_LONG) //
				.create(OPT_RECURSIVE_VALIDATION);
	}

	@SuppressWarnings("static-access")
	private Option createLogLevelOption() {
		return OptionBuilder//
				.withArgName("arg") //
				.withDescription("The log level (quiet or verbose)") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_LOG_LEVEL_LONG) //
				.create(OPT_LOG_LEVEL);
	}

	@SuppressWarnings("static-access")
	private Option createFileOption() {
		return OptionBuilder.withArgName("Franca IDL file").withDescription("Input file in Franca IDL (fidl) format.")
				.hasArg().isRequired().withValueSeparator(' ').create(FIDLFILE);
	}

	@SuppressWarnings("static-access")
	private Option createOutputDirOption() {
		return OptionBuilder//
				.withArgName("directory") //
				.withDescription("Set output directory") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_OUTDIR_LONG) //
				.create(OPT_OUTDIR);
	}

	@Override
	protected void logError(String message) {
		if (logError) {
			logger.error(message);
		}
	}

	@Override
	protected void logInfo(String message) {
		if (logInfo) {
			logger.info(message);
		}
	}

	@Override
	protected boolean checkCommandLineValues(CommandLine line) {
		if (line.hasOption(FIDLFILE)) {
			String fidlFile = line.getOptionValue(FIDLFILE);
			File fidl = new File(fidlFile);
			if (fidl.exists()) {
				return true;
			} else {
				logError("Cannot open Franca IDL file '" + fidlFile + "'.");
			}
		}
		// TODO: Add validation for outdir
		// TODO: Validation for loglevel -> check -verbose & -ll quiet (illegal arguments) 
		return false;
	}

	private FPreferencesWamp getPreferences() {
		return FPreferencesWamp.getInstance();
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

	public void setCommonDirectory(String optionValue) {
		logInfo("Common output directory: " + optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_COMMON_WAMP, optionValue);
	}

	public void setProxyDirectory(String optionValue) {
		logInfo("Proxy output directory: " + optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_PROXIES_WAMP, optionValue);
	}

	public void setStubDirectory(String optionValue) {
		logInfo("Stub output directory: " + optionValue);
		getPreferences().setPreference(PreferenceConstantsWamp.P_OUTPUT_STUBS_WAMP, optionValue);
	}

	public void setLogLevel(String optionValue) {
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
}
