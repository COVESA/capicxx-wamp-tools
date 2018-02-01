package org.genivi.commonapi.wamp.cli;

import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;

public interface WampGeneratorOptions {

	public static final String OPT_FIDL_FILE = "f";
	public static final String OPT_FIDL_FILE_LONG = "fidl";
	public static final String OPT_RECURSIVE_VALIDATION = "r";
	public static final String OPT_RECURSIVE_VALIDATION_LONG = "recursive-validation";
	public static final String OPT_LOG_LEVEL = "ll";
	public static final String OPT_LOG_LEVEL_LONG = "loglevel";
	public static final String LOG_LEVEL_VALUE_QUIET = "quiet";
	public static final String LOG_LEVEL_VALUE_VERBOSE = "verbose";
	public static final String OPT_OUTDIR = "d";
	public static final String OPT_OUTDIR_LONG = "dest";
	public static final String OPT_OUTDIR_COMMON = "dc";
	public static final String OPT_OUTDIR_COMMON_LONG = "dest-common";
	public static final String OPT_OUTDIR_PROXY = "dp";
	public static final String OPT_OUTDIR_PROXY_LONG = "dest-proxy";
	public static final String OPT_OUTDIR_STUB = "ds";
	public static final String OPT_OUTDIR_STUB_LONG = "dest-stub";
	public static final String OPT_OUTDIR_SUB = "dsub";
	public static final String OPT_OUTDIR_SUB_LONG = "dest-subdirs";
	public static final String OPT_LICENSE = "l";
	public static final String OPT_LICENSE_LONG = "license";
	public static final String OPT_NO_COMMON = "nc";
	public static final String OPT_NO_COMMON_LONG = "no-common";
	public static final String OPT_NO_STUB = "ns";
	public static final String OPT_NO_STUB_LONG = "no-stub";
	public static final String OPT_NO_PROXY = "np";
	public static final String OPT_NO_PROXY_LONG = "no-proxy";
	public static final String OPT_NO_CODE = "ng";
	public static final String OPT_NO_CODE_LONG = "no-gen";
	public static final String OPT_NO_SYNC_CALLS = "nsc";
	public static final String OPT_NO_SYNC_CALLS_LONG = "no-sync-calls";

	@SuppressWarnings("static-access")
	default public Option createFileOption() {
		return OptionBuilder//
				.withArgName("Franca IDL file")//
				.withDescription("Input file in Franca IDL (fidl) format") //
				.hasArg()//
				.isRequired()//
				.withValueSeparator(' ')//
				.withLongOpt(OPT_FIDL_FILE_LONG)//
				.create(OPT_FIDL_FILE);
	}

	@SuppressWarnings("static-access")
	default public Option createRecursiveValidationOption() {
		return OptionBuilder//
				.withArgName("recval")//
				.withDescription("Recursive validation")//
				.withLongOpt(OPT_RECURSIVE_VALIDATION_LONG) //
				.create(OPT_RECURSIVE_VALIDATION);
	}

	@SuppressWarnings("static-access")
	default public Option createLogLevelOption() {
		return OptionBuilder//
				.withArgName("quiet|verbose") //
				.withDescription("The log level") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_LOG_LEVEL_LONG) //
				.create(OPT_LOG_LEVEL);
	}

	@SuppressWarnings("static-access")
	default public Option createOutDirOption() {
		return OptionBuilder//
				.withArgName("dir") //
				.withDescription("Set output directory") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_OUTDIR_LONG) //
				.create(OPT_OUTDIR);
	}

	@SuppressWarnings("static-access")
	default public Option createOutDirCommonOption() {
		return OptionBuilder//
				.withArgName("dir") //
				.withDescription("The directory for the common code") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_OUTDIR_COMMON_LONG) //
				.create(OPT_OUTDIR_COMMON);
	}

	@SuppressWarnings("static-access")
	default public Option createOutDirProxyOption() {
		return OptionBuilder//
				.withArgName("dir") //
				.withDescription("The directory for proxy code") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_OUTDIR_PROXY_LONG) //
				.create(OPT_OUTDIR_PROXY);
	}

	@SuppressWarnings("static-access")
	default public Option createOutDirStubOption() {
		return OptionBuilder//
				.withArgName("dir") //
				.withDescription("The directory for stub code") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_OUTDIR_STUB_LONG) //
				.create(OPT_OUTDIR_STUB);
	}

	@SuppressWarnings("static-access")
	default public Option createOutputSubDirOption() {
		return OptionBuilder//
				.withArgName("dir") //
				.withDescription("Use subdir per interface") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_OUTDIR_SUB_LONG) //
				.create(OPT_OUTDIR_SUB);
	}

	// TODO: Add license option
	@SuppressWarnings("static-access")
	default public Option createLicenseOption() {
		return OptionBuilder//
				.withArgName("filepath") //
				.withDescription("The file path to the license text that will be added to each generated file") //
				.hasArg() //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_LICENSE_LONG) //
				.create(OPT_LICENSE);
	}
	
	@SuppressWarnings("static-access")
	default public Option createNoCommonOption() {
		return OptionBuilder//
				.withDescription("Switch off generation of common code") //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_NO_COMMON_LONG) //
				.create(OPT_NO_COMMON);
	}
	
	@SuppressWarnings("static-access")
	default public Option createNoStubOption() {
		return OptionBuilder//
				.withDescription("Switch off generation of stub code") //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_NO_STUB_LONG) //
				.create(OPT_NO_STUB);
	}

	@SuppressWarnings("static-access")
	default public Option createNoProxyOption() {
		return OptionBuilder//
				.withDescription("Switch off generation of proxy code") //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_NO_PROXY_LONG) //
				.create(OPT_NO_PROXY);
	}
	
	@SuppressWarnings("static-access")
	default public Option createNoCodeOption() {
		return OptionBuilder//
				.withDescription("Switch off code generation") //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_NO_CODE_LONG) //
				.create(OPT_NO_CODE);
	}
	
	@SuppressWarnings("static-access")
	default public Option createNoSyncCallsOption() {
		return OptionBuilder//
				.withDescription("Switch off code generation") //
				.withValueSeparator(' ') //
				.withLongOpt(OPT_NO_SYNC_CALLS_LONG) //
				.create(OPT_NO_SYNC_CALLS);
	}

}
