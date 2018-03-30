#!/bin/bash

cd ../

for D in {0..30}; do
	printf "Executing on hydra%02d... " ${D}
	ssh -q hydra${D}.eecs.utk.edu nice -n 19 ~/wrkspc/cs420_bm/proj3/hopfield_mpi 5000 10000 1 > experiments/ex6_hydra/test_${D}.csv &
	printf "Running!\n"
done

wait
printf "All Jobs are complete!\n"
