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
import java.util.Arrays;
import java.util.List;
import java.util.Set;

import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.genivi.commonapi.core.preferences.FPreferences;

import com.google.inject.Inject;

/**
 * @author Markus Mühlbrandt
 * 
 */
public class MochaTestHelper {

	private static final String BUILD_FOLDER_NAME = "build";

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
		
		String inputFile = getModelAnnotation();
		// load model
		FModel fmodel = loader.loadModel(inputFile);
		assertNotNull("Could not load model from file: " + inputFile, fmodel);

		fsa.setOutputConfigurations(FPreferences.getInstance().getOutputpathConfiguration());

		generators.forEach(generator -> generator.doGenerate(fmodel.eResource(), fsa));
	}

	public void compile() {
		Path buildPath = getBuildDirectory();
		try {
			if (Files.exists(buildPath)) {
				Files2.clear(buildPath);
			} else {
				Files.createDirectory(buildPath);
			}

		} catch (IOException e) {
			e.printStackTrace();
		}

		List<String> command = createCommand("cmake", "..");
		getCommandExecutor().startProcess(command, buildPath.toFile());

		command = createCommand("make");
		getCommandExecutor().startProcess(command, buildPath.toFile());
	}

	public void startServer() {
		//TODO: Remove sleep time
		List<String> command = createCommand(getCrossbarIOExecutable().toString(), "start");
		crossbarIOProcess = getCommandExecutor().startProcess(command, getTestsBaseDirectory().toFile(), true);
		try {
			Thread.sleep(2000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		command = createCommand(getCommonAPIServiceExecutable().toString());
		commonAPIServiceProcess = getCommandExecutor().startProcess(command, getTestSourceDirectory().toFile(), true);
		try {
			Thread.sleep(2000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public Process getCommonAPIServiceProcess() {
		return commonAPIServiceProcess;
	}
	
	public Process getCrossbarIOProcess() {
		return crossbarIOProcess;
	}

	private Path getBuildDirectory() {
		return Paths.get(System.getProperty("user.dir"), BUILD_FOLDER_NAME);
	}

	private Path getCrossbarIOExecutable() {
		return Paths.get(System.getProperty("user.home"), ".local", "bin", "crossbar");
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

	protected List<String> getFilesToCopy() {
		return new ArrayList<String>(
				Arrays.asList(owner.getClass().getAnnotation(MochaTest.class).additionalFilesToCopy()));
	}

	protected List<String> getFilesToCompile() {
		return new ArrayList<String>(
				Arrays.asList(owner.getClass().getAnnotation(MochaTest.class).additionalFilesToCompile()));
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

	protected String getTestBundleAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).testBundle();
	}

	protected String getModelBundleAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).modelBundle();
	}

	protected String getServiceNameAnnotation() {
		return owner.getClass().getAnnotation(MochaTest.class).serviceName();
	}
}
