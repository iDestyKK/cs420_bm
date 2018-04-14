#!/bin/bash

function run() {
	printf "Experiment ${1}... "
	mkdir "experiments/${1}"
	for D in {1..5}; do
		printf "${D} "
		if [ ! -e "experiments/${1}/data${D}.csv" ]; then
			./run.sh $2 $3 $4 $5 $6 > "experiments/${1}/data${D}.csv"
		fi
	done
	printf "Done!\n"
}

# Go out of the "scr" directory
cd ../

# Check if "run.sh" exists.
if [ ! -e "run.sh" ]; then
	printf "[ERROR] \"run.sh\" doesn't exist!\n"
	exit 1
fi

# Perform experiments
run 01 20   30   10 0.0330 0.6
run 02 30   30   10 0.0330 0.6
run 03 20   40   10 0.0330 0.6
run 04 20  100   10 0.0330 0.6
run 05 20   30   10 0.0330 1.0
run 06  5   30   10 0.0330 0.6
run 07 20   30   10 1.0000 0.6
run 08 30 3000  100 0.0330 0.6
run 09 50 3000  100 0.0001 1.0
run 10 50 3000 1000 0.0001 1.0
