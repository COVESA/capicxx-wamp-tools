/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.mocha;

import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.List;

/**
 * Helper class to execute third party programs.
 * 
 * @author Markus Mühlbrandt
 *
 */
public class CommandExecutor {

	public void startProcess(List<String> command, File directory) {
		startProcess(command, directory, false, 0);
	}

	public Process startProcess(List<String> command, File directory, boolean isService, long wait) {

		ProcessBuilder processBuilder = new ProcessBuilder(command).directory(directory);
		Process process = null;
		try {
			process = processBuilder.redirectErrorStream(true).start();

			if (!isService) {
				waitForProcessTermination(process);
			} else if (wait >= 0) {
				Thread.sleep(wait);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		return process;
	}

	public void waitForProcessTermination(Process process) throws IOException {
		String message = readProcessInputStream(process);
		boolean wait = true;
		int exitCode = 0;

		do {
			wait = false;
			// waiting for the processes termination
			try {
				process.waitFor();
			} catch (InterruptedException e) {
				// we ignore if waiting was interrupted ...
			}

			// if we get an exit code then we know that the process is finished
			try {
				exitCode = process.exitValue();
			} catch (IllegalThreadStateException e) {
				// if we get an exception then the process has not finished ...
				wait = true;
			}
		} while (wait);

		if (exitCode != 0) {
			throw new RuntimeException("Execution failed (exit status " + process.exitValue() + "):\n" + message);
		}
	}

	private String readProcessInputStream(Process process) throws IOException {
		Reader reader = new InputStreamReader(process.getInputStream());
		char[] buffer = new char[4096];
		int count;
		StringBuilder message = new StringBuilder();
		while ((count = reader.read(buffer)) != -1) {
			message.append(buffer, 0, count);
		}
		return message.toString();
	}
}
