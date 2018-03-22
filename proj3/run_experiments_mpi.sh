#!/bin/bash

function run {
	# void run(num, patterns, neurons, repetitions, file)
	printf "EXPERIMENT $1: Hopfield Sim (P: $2, N: $3, R: $4)" \
		>> experiments/times_mpi.dat

	printf "Running Experiment #%d... " $1
	{ nice -n 19 time mpiexec -np 8 ./hopfield_mpi $2 $3 $4 > $5 ; } >> experiments/times_mpi.dat 2>&1
	printf "Done!\n"

	printf "\n" >> experiments/times_mpi.dat
}

# Wipe out the time data file
> experiments/times_mpi.dat

run 1 50    100   50 experiments/mpi_ex1.csv
run 2 100   100   50 experiments/mpi_ex2.csv
run 3 50    200   50 experiments/mpi_ex3.csv
run 4 100   200   50 experiments/mpi_ex4.csv
run 5 1000  2000  50 experiments/mpi_ex5.csv
run 6 10000 20000 50 experiments/mpi_ex6.csv
