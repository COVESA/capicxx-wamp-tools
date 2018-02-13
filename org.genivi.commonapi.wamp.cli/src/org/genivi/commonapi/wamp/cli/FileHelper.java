package org.genivi.commonapi.wamp.cli;

public final class FileHelper {

	private static final String FILESEPARATOR = System.getProperty("file.separator");
	
	/**
	 * creates a absolute path from a relative path which starts on the current user
	 * directory
	 *
	 * @param path
	 *            the relative path which start on the current user-directory
	 * @return the created absolute path
	 */
	public static String createAbsolutPath(String path) {
		return createAbsolutPath(path, System.getProperty("user.dir") + FILESEPARATOR);
	}
	
	/**
	 * Here we create an absolute path from a relativ path and a rootpath from which
	 * the relative path begins
	 *
	 * @param path
	 *            the relative path which begins on rootpath
	 * @param rootpath
	 *            an absolute path to a folder
	 * @return the merded absolute path without points
	 */
	private static String createAbsolutPath(String path, String rootpath) {
		if (System.getProperty("os.name").contains("Windows")) {
			if (path.startsWith(":", 1))
				return path;
		} else {
			if (path.startsWith(FILESEPARATOR))
				return path;
		}

		String ret = (rootpath.endsWith(FILESEPARATOR) ? rootpath : (rootpath + FILESEPARATOR)) + path;
		while (ret.contains(FILESEPARATOR + "." + FILESEPARATOR)
				|| ret.contains(FILESEPARATOR + ".." + FILESEPARATOR)) {
			if (ret.contains(FILESEPARATOR + ".." + FILESEPARATOR)) {
				String temp = ret.substring(0, ret.indexOf(FILESEPARATOR + ".."));
				temp = temp.substring(0, temp.lastIndexOf(FILESEPARATOR));
				ret = temp + ret.substring(ret.indexOf(FILESEPARATOR + "..") + 3);
			} else {
				ret = replaceAll(ret, FILESEPARATOR + "." + FILESEPARATOR, FILESEPARATOR);
			}
		}
		return ret;
	}

	/**
	 * a relaceAll Method which doesn't interprets the toreplace String as a regex
	 * and so you can also replace \ and such special things
	 *
	 * @param text
	 *            the text who has to be modified
	 * @param toreplace
	 *            the text which has to be replaced
	 * @param replacement
	 *            the text which has to be inserted instead of toreplace
	 * @return the modified text with all toreplace parts replaced with replacement
	 */
	private static String replaceAll(String text, String toreplace, String replacement) {
		String ret = "";
		while (text.contains(toreplace)) {
			ret += text.substring(0, text.indexOf(toreplace)) + replacement;
			text = text.substring(text.indexOf(toreplace) + toreplace.length());
		}
		ret += text;
		return ret;
	}

}
