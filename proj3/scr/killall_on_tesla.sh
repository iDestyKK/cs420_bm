#!/bin/bash

cd ../

for D in {0..30}; do
	printf "Killing all on tesla%02d... " ${D}
	ssh -q tesla${D}.eecs.utk.edu killall hopfield_mpi
	printf "Done!\n"
done
