#!/bin/bash

cd ../

for D in {0..30}; do
	printf "Executing on hydra%02d... " ${D}
	ssh -q hydra${D}.eecs.utk.edu nice -n 19 mpiexec -np 4 ~/wrkspc/cs420_bm/proj3/hopfield_mpi 10000 20000 1 > experiments/ex6_hydra/test_${D}.csv &
	printf "Running!\n"
done

for D in {0..20}; do
	printf "Executing on tesla%02d... " ${D}
	ssh -q tesla${D}.eecs.utk.edu nice -n 19 mpiexec -np 4 ~/wrkspc/cs420_bm/proj3/hopfield_mpi 10000 20000 1 > experiments/ex6_tesla/test_${D}.csv &
	printf "Running!\n"
done

wait
printf "All Jobs are complete!\n"
