#!/bin/bash

cd ../

function run {
	# void run(num, patterns, neurons, repetitions, file)
	printf "EXPERIMENT $1: Hopfield Sim (P: $2, N: $3, R: $4)" \
		>> experiments/times.dat

	printf "Running Experiment #%d... " $1
	{ time ./hopfield $2 $3 $4 > $5 ; } >> experiments/times.dat 2>&1
	printf "Done!\n"

	printf "\n" >> experiments/times.dat
}

# Wipe out the time data file
> experiments/times.dat

run 1 50 100 50      experiments/ex1.csv
run 2 100 100 50     experiments/ex2.csv
run 3 50 200 50      experiments/ex3.csv
run 4 100 200 50     experiments/ex4.csv
run 5 1000 2000 50   experiments/ex5.csv
run 6 10000 20000 50 experiments/ex6.csv
