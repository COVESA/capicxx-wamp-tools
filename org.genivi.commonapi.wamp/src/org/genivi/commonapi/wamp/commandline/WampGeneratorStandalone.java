package org.genivi.commonapi.wamp.commandline;

import java.io.File;
import java.util.Map;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.eclipse.xtext.generator.OutputConfigurationProvider;
import org.franca.core.franca.FModel;
import org.genivi.commonapi.wamp.WampGeneratorFrancaStandaloneSetup;

import com.google.common.collect.Maps;
import com.google.inject.Inject;

/**
 * Runner for standalone CommonAPI/WAMP generation from Franca files.
 *  
 * @author Klaus Birken (itemis)
 */
public class WampGeneratorStandalone extends AbstractCommandLineTool {

	// prepare class for logging....
	private static final Logger logger = Logger.getLogger(WampGeneratorStandalone.class);

	private static final String TOOL_VERSION = "0.7.0";

	// specific option values
	private static final String FIDLFILE = "f";
	private static final String RECURSIVE_VALIDATION = "r";
	
	/**
	 * The main function for this standalone tool.</p>
	 * 
	 * It directly hands over control to the CommandLineTool framework.
	 * 
	 * @param args the collection of command line arguments
	 */
	public static void main(String[] args) {
		// hand over control to CommandLineTool framework
		execute(new WampGeneratorFrancaStandaloneSetup(), TOOL_VERSION, WampGeneratorStandalone.class, args);
	}

	// injected fragments
	@Inject IGenerator generator;

	@Override
	protected int run(CommandLine line) {
		// print version string
//		System.out.println(VERSIONSTR);

		// TODO configure Logger depends on given verbose value
//		boolean verbose = line.hasOption(VERBOSE);
		
		// load Franca IDL file
		String fidlFile = line.getOptionValue(FIDLFILE);
		FModel fmodel = persistenceManager.loadModel(fidlFile);
		if (fmodel==null) {
			logger.error("Couldn't load Franca IDL file '" + fidlFile + "'.");
			return -1;
		}
//		logger.info("Franca IDL: package '" + fmodel.getName() + "'");

		// call validator
		int nErrors = validateModel(fmodel, line.hasOption(RECURSIVE_VALIDATION));
		if (nErrors>0) {
			System.err.println("Validation of Franca model: " + nErrors + " errors, aborting.");
			return -1;
		}
		
		// call generator and save files
		JavaIoFileSystemAccess fsa = injector.getInstance(JavaIoFileSystemAccess.class);
		if (line.hasOption(CommonOptions.OUTDIR)) {
			String outPath = line.getOptionValue(CommonOptions.OUTDIR);
			Map<String, OutputConfiguration> configs = Maps.newHashMap();
			addOutputConfig(configs, fsa.DEFAULT_OUTPUT, outPath);
			addOutputConfig(configs, "outputDirProxies", outPath);
			addOutputConfig(configs, "outputDirStubs", outPath);
			fsa.setOutputConfigurations(configs);
		}
		generator.doGenerate(fmodel.eResource(), fsa);

//		logger.info("FrancaStandaloneGen done.");
		return 0;
	}
	
	private void addOutputConfig(Map<String, OutputConfiguration> configs, String name, String path) {
		OutputConfiguration cfg = new OutputConfiguration(name);
		cfg.setCreateOutputDirectory(true);
		cfg.setOutputDirectory(path);
		configs.put(name, cfg);
	}

	@SuppressWarnings("static-access")
	@Override
	protected void addOptions(Options options) {
		// String[] set = LogFactory.getLog(getClass()).

		// required
		Option optInputFidl = OptionBuilder.withArgName("Franca IDL file")
				.withDescription("Input file in Franca IDL (fidl) format.").hasArg().isRequired()
				.withValueSeparator(' ').create(FIDLFILE);
		//optInputFidl.setType(File.class);
		options.addOption(optInputFidl);

		// option for configuration of an output directory 
		CommonOptions.createOutdirOption(options);

		Option optRecursiveValidation = OptionBuilder.withArgName("recval")
		.withDescription("Recursive validation").hasArg(false)
		.isRequired(false).create(RECURSIVE_VALIDATION);
		options.addOption(optRecursiveValidation);
	}

	@Override
	protected void logError(String message) {
		logger.error(message);
	}
	
	@Override
	protected void logInfo(String message) {
		logger.info(message);
	}
	
	@Override
	protected boolean checkCommandLineValues(CommandLine line) {
		if (line.hasOption(FIDLFILE)) {
			String fidlFile = line.getOptionValue(FIDLFILE);
			File fidl = new File(fidlFile);
			if (fidl.exists()) {
				return true;
			} else {
				logger.error("Cannot open Franca IDL file '" + fidlFile + "'.");
			}
		}
		return false;
	}
}
