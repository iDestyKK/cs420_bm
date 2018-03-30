#!/bin/bash

id=0
count=0
limit=20

rm -f master.csv
touch master.csv
count=0
cat data/param3.txt | while read line; do
	idstr=$(printf "%03d" $count)
	if [ -e results/ex3/${idstr}_1.csv ]; then
		printf "\"Experiment #%d\"\n" $count >> master.csv
		python \
			"data/csv_2avg.py"         \
			results/ex3/${idstr}_1.csv \
			results/ex3/${idstr}_2.csv \
			results/ex3/${idstr}_3.csv \
			results/ex3/${idstr}_4.csv \
			>> master.csv
	fi
	let "count++"
done

exit 1
cat data/param3.txt | while read line; do
	for r in {1..4}; do
		iterations=0
		zed_count=0

		# Try running the program 10 times. If we get 0 on everything, nope.
		while [ $iterations -ne 50 ]; do
			printf "\rExecuting case #%d run %d (%d)..." $count $r $iterations

			# Execute
			eval "./run.sh $line" > /dev/null 2> /dev/null

			# Compute how stupid the test run was.
			zed_count=$(cat result.csv | grep "^[0-9]\+,0," | wc -l)

			# If it wasn't 0, keep it.
			if [ $zed_count -ne 15 ]; then
				break
			fi
			if [ $r -eq 1 ]; then
				let "iterations++"
			fi
		done

		if [ $iterations -eq 50 ]; then
			# Skip the entire test case
			printf "Failed!\n" $count
			idstr=$(printf "%03d" $count)
			rm -f results/ex3/${idstr}_*.*
			break
		fi
		
		if [ $zed_count -eq 15 ]; then
			printf "Failed!\n" $count
		else
			printf "Passed!\n" $count
			idstr=$(printf "%03d" $count)
			mv result.gif results/ex3/${idstr}_${r}.gif
			mv result.csv results/ex3/${idstr}_${r}.csv
		fi
	done

	let "count++"
done
