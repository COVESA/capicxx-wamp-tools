#!/bin/bash
TITLE="GENIVI Wamp generator executable JAR downloads"
echo -e "Create HTML index file for standalone jars...\n"
cd ../target/gh-pages/standalone
tree -H '.' -T "${TITLE}" -L 2 --noreport --charset utf-8 -P "*.jar" > index.html
echo -e "Created index.html.\n"
