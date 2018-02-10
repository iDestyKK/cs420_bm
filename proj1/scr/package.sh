#!/bin/bash
#
# COSC 420: Project 1 Packager
#
# Will package up your homework for submission yo.
#

# Get the path of this script
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Go back a directory
cd "${SCRIPTPATH}/../"

submit_dir="submit"

tar -cvf \
	${submit_dir}/"proj1.tar"  \
	"1 - Edge of Chaos.pdf"    \
	\
	-C "doc"                   \
	    "MasterExperiment.xlsx"
