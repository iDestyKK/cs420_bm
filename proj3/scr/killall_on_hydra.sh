#!/bin/bash

cd ../

for D in {0..30}; do
	printf "Killing all on hydra%02d... " ${D}
	ssh -q hydra${D}.eecs.utk.edu killall hopfield_mpi
	printf "Done!\n"
done

#for D in {0..20}; do
#	printf "Killing all on tesla%02d... " ${D}
#	ssh -q tesla${D}.eecs.utk.edu killall hopfield_mpi
#	printf "Done!\n"
#done
