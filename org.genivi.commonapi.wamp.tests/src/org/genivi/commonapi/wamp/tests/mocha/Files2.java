/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 *******************************************************************************/
package org.genivi.commonapi.wamp.tests.mocha;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;

public final class Files2 {

	public static void clear(Path path) throws IOException {
		if (Files.exists(path)) {
			deleteRecursively(path);
		}
		Files.createDirectory(path);
	}

	public static void deleteRecursively(Path root) throws IOException {
		Files.walk(root)//
				.sorted(Comparator.reverseOrder())//
				.forEach(path -> {
					try {
						Files.delete(path);
					} catch (IOException e) {
						e.printStackTrace();
					}
				});
	}

	public static Path removeLastSegment(Path path) {
		if (path != null && path.getNameCount() > 1) {
			return Paths.get("/",path.subpath(0, path.getNameCount() - 1).toString());
		}
		return path;
	}
}
