/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.mocha;

import static org.junit.Assert.assertNotNull;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.genivi.commonapi.core.preferences.FPreferences;
import org.genivi.commonapi.core.preferences.PreferenceConstants;

import com.google.inject.Inject;

/**
 * @author Markus Mühlbrandt
 * 
 */
public class MochaTestHelper {

	private static final String BUILD_FOLDER_NAME = "build";
	private static final String SRC_GEN_FOLDER_NAME = "src-gen";
	private static final Path CROSSBAR_IO_PATH = Paths.get("crossbar");
	private static final int CROSSBAR_IO_STARTUPTIME = 2000;
	private static final int SERVICE_STARTUP_TIME = 1000;

	private final Object owner;
	protected Compiler compiler;
	@Inject
	protected FrancaPersistenceManager loader;
	@Inject
	protected Set<IGenerator> generators;
	@Inject
	protected JavaIoFileSystemAccess fsa;
	protected Process crossbarIOProcess;
	protected Process commonAPIServiceProcess;

	public MochaTestHelper(Object owner) {
		this.owner = owner;
	}

	@SuppressWarnings("deprecation")
	public void generate() {
		Path srcPath = getGeneratedSourceDirectory();
		clearDirectory(srcPath);

		String inputFile = getModelAnnotation();
		// load model
		FModel fmodel = loader.loadModel(inputFile);
		assertNotNull("Could not load model from file: " + inputFile, fmodel);

		FPreferences instance = FPreferences.getInstance();
		instance.setPreference(PreferenceConstants.P_GENERATE_SKELETON, generateSkeleton());
		fsa.setOutputConfigurations(instance.getOutputpathConfiguration());

		generators.forEach(generator -> generator.doGenerate(fmodel.eResource(), fsa));
	}

	public void compile() {
		Path buildPath = getBuildDirectory();
		clearDirectory(buildPath);
		String testFolderName = getTestFolderName();
		List<String> command = createCommand("cmake", "..", "-DPRJ_NAME:STRING=" + toFirstUpper(testFolderName),
				"-DPRJ_FOLDER:String=" + testFolderName);
		getCommandExecutor().startProcess(command, buildPath.toFile());

		command = createCommand("make");
		getCommandExecutor().startProcess(command, buildPath.toFile());
	}

	public void startServer() {
		List<String> command = createCommand(getCrossbarIOExecutable().toString(), "start");
		crossbarIOProcess = getCommandExecutor().startProcess(command, getTestsBaseDirectory().toFile(), true, CROSSBAR_IO_STARTUPTIME);

		command = createCommand(getCommonAPIServiceExecutable().toString());
		commonAPIServiceProcess = getCommandExecutor().startProcess(command, getTestSourceDirectory().toFile(), true,
				SERVICE_STARTUP_TIME);
	}

	public Process getCommonAPIServiceProcess() {
		return commonAPIServiceProcess;
	}

	public Process getCrossbarIOProcess() {
		return crossbarIOProcess;
	}

	private Path getGeneratedSourceDirectory() {
		return Paths.get(System.getProperty("user.dir"), SRC_GEN_FOLDER_NAME);
	}

	private Path getBuildDirectory() {
		return Paths.get(System.getProperty("user.dir"), BUILD_FOLDER_NAME);
	}

	private Path getCrossbarIOExecutable() {
		return CROSSBAR_IO_PATH;
	}

	private Path getCommonAPIServiceExecutable() {
		return Paths.get(getBuildDirectory().toString(), getServiceNameAnnotation());
	}

	private Path getTestSourceDirectory() {
		return Files2.removeLastSegment(getTestSourceFile());
	}

	private Path getTestsBaseDirectory() {
		return Files2.removeLastSegment(getTestSourceDirectory());
	}

	private Path getTestSourceFile() {
		return Paths.get(System.getProperty("user.dir"), getTestSourceFileAnnotation());
	}

	protected List<String> createCommand(String cmd, String... args) {
		List<String> command = new ArrayList<String>();
		command.add(cmd);
		for (String arg : args) {
			command.add(arg);
		}
		return command;
	}

	protected String generateSkeleton() {
		if (getGenerateSkeletonAnnotation()) {
			return "true";
		}
		return "false";
	}

	protected CommandExecutor getCommandExecutor() {
		return new CommandExecutor();
	}

	protected String getTestSourceFileAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).mochaTestFile();
	}

	protected String getModelAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).model();
	}

	protected String getServiceNameAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).serviceName();
	}

	protected boolean getGenerateSkeletonAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).generateSkeleton();
	}

	private void clearDirectory(Path path) {
		try {
			if (Files.exists(path)) {
				Files2.clear(path);
			} else {
				Files.createDirectory(path);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private String getTestFolderName() {
		return getTestSourceDirectory().getFileName().toString();
	}

	private String toFirstUpper(String input) {
		return Character.toUpperCase(input.charAt(0)) + input.substring(1);
	}
}
