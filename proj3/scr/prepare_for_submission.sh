#!/bin/bash
#
# COSC 420: Project 3 Packager
#
# Will package up your homework for submission yo.
#

# Get the path of this script
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Go back a directory
cd "${SCRIPTPATH}/../"

submit_dir="submit"

# Make submission directory if it doesn't already exist
mkdir "${submit_dir}" \
     > /dev/null      \
	2> /dev/null

# Package everything up. Have a nice day.
tar -cvf \
	${submit_dir}/"proj3.tar" \
	"3 - Hopfield Net.pdf"    \
	"makefile"                \
	"bin"                     \
	"doc"                     \
	"experiments"             \
	"scr"                     \
	"src"
