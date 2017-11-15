package org.genivi.commonapi.wamp.tests.mocha;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.runner.Description;
import org.junit.runner.Runner;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunNotifier;
import org.junit.runners.model.InitializationError;
import org.osgi.framework.Bundle;
import org.osgi.framework.FrameworkUtil;

import com.google.common.collect.Lists;

import junit.framework.AssertionFailedError;

/**
 * Runner to execute Mocha JavaScript tests within JUnit test.
 * 
 * @author Markus Mühlbrandt
 *
 */
public class MochaTestRunner extends Runner {

	// private static final Pattern TEST_PATTERN =
	// Pattern.compile("TEST(?:_F)?\\s*\\(\\s*(\\w+)\\s*,\\s*(\\w+)\\s*\\)");
	private static final Pattern TEST_PATTERN = Pattern
			.compile("describe\\(\\s*'((\\w+|\\s*)*)',\\s*|\\w*it\\(\\s*'((\\w+|\\s*)*)',");
	private static final Pattern SL_COMMENT_PATTERN = Pattern
			.compile("//.*(?:\\r?\\n|\\z)");
	private static final Pattern ML_COMMENT_PATTERN = Pattern
			.compile("(?:/\\*(?:[^*]|(?:\\*+[^*/]))*\\*+/)|(?://.*)");
	private static final Pattern TEST_OUTPUT_PATTERN = Pattern
			.compile("\\[\\s*(\\w+)\\s*\\] (\\w+)\\.(\\w+)");

	private boolean ignore;
	private Class<?> testClass;
	private Map<String, List<String>> testCases = new LinkedHashMap<String, List<String>>();

	private class TestOutput {

		public static final int RUN = 0;
		public static final int OK = 1;
		public static final int FAILED = 2;

		private int status;

		private String testPackageName;
		private String testName;

		public TestOutput(int status, String testPackageName, String testName) {
			this.status = status;
			this.testPackageName = testPackageName;
			this.testName = testName;
		}

		/**
		 * @return the status
		 */
		public int getStatus() {
			return status;
		}

		public Description toDescription() {
			String name;
			if (testCases.size() == 1) {
				name = testName;
			} else {
				name = testPackageName + "." + testName;
			}
			return Description.createTestDescription(testClass, name);
		}

	}

	public MochaTestRunner(Class<?> testClass) throws InitializationError {
		this.testClass = testClass;

		MochaTest annotation = testClass.getAnnotation(MochaTest.class);
		if (annotation == null) {
			throw new InitializationError("Test class must specify "
					+ MochaTest.class.getCanonicalName() + " annotation");
		}

		ignore = testClass.getAnnotation(Ignore.class) != null;

		String sourceFile = annotation.sourceFile();
		try {
			CharSequence charSequence = readSourceFile(sourceFile);
			String s = ML_COMMENT_PATTERN.matcher(
					SL_COMMENT_PATTERN.matcher(charSequence).replaceAll(""))
					.replaceAll("");
			Matcher matcher = TEST_PATTERN.matcher(s);
			String testPackageName = "";
			while (matcher.find()) {
				String packageName = matcher.group(1);
				if (packageName != null && !packageName.isEmpty()) {
					testPackageName = packageName;
				}
				String testName = matcher.group(3);
				if (testName != null && !testName.isEmpty()) {
					List<String> packageTests = testCases.get(testPackageName);
					if (packageTests == null) {
						packageTests = new ArrayList<String>();
						testCases.put(testPackageName, packageTests);
					}
					packageTests.add(testName);
				}
			}
		} catch (IOException e) {
			throw new InitializationError(e);
		}

		if (testCases.isEmpty()) {
			throw new InitializationError("No tests specified");
		}
	}

	@Override
	public Description getDescription() {
		Description description = Description.createSuiteDescription(testClass);
		for (Entry<String, List<String>> entry : testCases.entrySet()) {
			for (String test : entry.getValue()) {
				String testPackage = entry.getKey();
				Description childDescription = createDescription(testPackage,
						test);
				description.addChild(childDescription);
			}
		}
		return description;
	}

	private Description createDescription(String testPackage, String test) {
		String name;
		if (testCases.size() == 1) {
			name = test;
		} else {
			name = testPackage + "." + test;
		}
		return Description.createTestDescription(testClass, name);
	}

	@Override
	public void run(RunNotifier notifier) {
		if (ignore) {
			notifier.fireTestIgnored(getDescription());
		} else {
			try {
				Object test = testClass.newInstance();
				Method[] methods = testClass.getMethods();

				for (Method method : methods) {
					if (method.isAnnotationPresent(Before.class)) {
						method.invoke(test);
					}
				}

				runTests(notifier);

				for (Method method : methods) {
					if (method.isAnnotationPresent(After.class)) {
						method.invoke(test);
					}
				}
			} catch (InvocationTargetException e) {
				Throwable targetException = ((InvocationTargetException) e)
						.getTargetException();
				notifier.fireTestFailure(new Failure(getDescription(),
						targetException));
			} catch (Throwable throwable) {
				notifier.fireTestFailure(new Failure(getDescription(),
						throwable));
			}
		}
	}

	private CharSequence readSourceFile(String sourceFile) throws IOException {
		Bundle bundle = getTestBundle();
		// System.out.println("[MochaTestRunner] Loaded bundle " +
		// bundle.getSymbolicName());
		InputStream is = FileLocator.openStream(bundle, new Path(sourceFile),
				false);
		Reader reader = new InputStreamReader(is);
		char[] buffer = new char[4096];
		StringBuilder sb = new StringBuilder(buffer.length);
		int count;
		while ((count = reader.read(buffer)) != -1) {
			sb.append(buffer, 0, count);
		}
		reader.close();
		is.close();
		return sb;
	}

	protected Bundle getTestBundle() {
		String testProject = testClass.getAnnotation(MochaTest.class)
				.testBundle();
		if (!testProject.isEmpty()) {
			Bundle testBundle = Platform.getBundle(testProject);
			if (testBundle != null) {
				return testBundle;
			}
		}
		return FrameworkUtil.getBundle(testClass);
	}

	private void runTests(RunNotifier notifier) throws IOException,
			InterruptedException {
		String program = testClass.getAnnotation(MochaTest.class).program();
		String sourceFile = testClass.getAnnotation(MochaTest.class)
				.sourceFile();
		// if (Platform.getOS().equalsIgnoreCase(Platform.OS_WIN32)) {
		// program += ".exe";
		// }
		String targetProject = testClass.getAnnotation(MochaTest.class)
				.testBundle();
		IPath programPath = new Path(targetProject).append(sourceFile);
		IResource programFile = ResourcesPlugin.getWorkspace().getRoot()
				.findMember(programPath);
		IContainer programContainer = programFile.getParent();
		if (!programContainer.isAccessible()) {
			throw new RuntimeException("Test program container "
					+ programContainer.getLocation().toOSString()
					+ " inaccessible");
		}

		File directory = programContainer.getLocation().toFile();
		String sourceFileName = sourceFile.substring(sourceFile
				.lastIndexOf('/') + 1);
		List<String> command = Lists.newArrayList(program, sourceFileName,
				"-R", "reporter.js");
		Process process = new ProcessBuilder(command).redirectErrorStream(true)
				.directory(directory).start();
		BufferedReader reader = new BufferedReader(new InputStreamReader(
				process.getInputStream()));

		boolean started = false;
		boolean running = false;
		StringBuilder message = new StringBuilder();
		String line;
		while ((line = reader.readLine()) != null) {
			if (line.startsWith("[====")) {
				if (started) {
					started = false;
					// Eat remaining input
					char[] buffer = new char[4096];
					while (reader.read(buffer) != -1)
						;
					break;
				}
				started = true;
			} else {
				TestOutput testOutput = parseTestOutput(line);
				if (testOutput != null) {
					Description description = testOutput.toDescription();
					switch (testOutput.getStatus()) {
					case TestOutput.RUN:
						running = true;
						message.setLength(0);
						notifier.fireTestStarted(description);
						break;
					case TestOutput.OK:
						running = false;
						notifier.fireTestFinished(description);
						break;
					default:
						running = false;
						notifier.fireTestFailure(new Failure(description,
								new AssertionFailedError(message.toString())));
						notifier.fireTestFinished(description);
						break;
					}
				} else if (running) {
					message.append(line);
					message.append("\n");
				}
			}
		}

		process.waitFor();

		if (started) {
			throw new RuntimeException("Test quit unexpectedly (exit status "
					+ process.exitValue() + "):\n" + message);
		}
	}

	private TestOutput parseTestOutput(String s) {
		Matcher matcher = TEST_OUTPUT_PATTERN.matcher(s);
		if (matcher.find()) {
			String statusString = matcher.group(1);
			int status;
			if ("RUN".equals(statusString)) {
				status = TestOutput.RUN;
			} else if ("OK".equals(statusString)) {
				status = TestOutput.OK;
			} else {
				status = TestOutput.FAILED;
			}
			String testPackageName = matcher.group(2);
			String testName = matcher.group(3);
			return new TestOutput(status, testPackageName, testName);
		}
		return null;
	}
}
