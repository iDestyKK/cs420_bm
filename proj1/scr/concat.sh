#!/bin/bash

# Get the path of this script
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Go to the experiments directory
cd "${SCRIPTPATH}/../experiments"

# Now handle shit

# HTML Header
printf "<html><body>\n"

# Body
for F in $(ls -1 *.html | sort -V); do
	cat "${F}" | sed \
		-e 's/^<html>.*$//' \
		-e 's/<body>//'     \
		-e 's/^\(.*\)<\/body><\/html>$/\1/'
done

# Closing tags
printf "</body></html>\n"
