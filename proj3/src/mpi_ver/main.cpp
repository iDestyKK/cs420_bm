/*
 * COSC 420 - Project 3: Hopfield Network (MPI Version)
 *
 * Description (UK):
 *     Simulates a Hopfield network consisting of (by default) 50 patterns and
 *     100 neurons in each pattern. The goal is to get information by running
 *     the simulation multiple times, and then averaging the data. This is done
 *     for both the unstable imprint fraction and the number of stable imprints
 *     from p=1 until p=50.
 *
 *     For the sake of extra credit, the program fully takes advantage of C++,
 *     allowing for a completely Object Oriented Interface that allows users to
 *     customise how the program acts during each and every run. They can 
 *     configure the number of patterns, neurons, and simulations run by this
 *     simulator.
 *
 *     This is threaded via OpenMPI. It is recommended that you break off the
 *     threads into multiple nodes that can do the computations in teams.
 *     Because the computation does not actually require any prior information,
 *     every node can act independently and still return the same information.
 *
 * Synopsis:
 *     ./hopfield patterns neurons simulations
 *
 * Default:
 *     ./hopfield 50 100 50
 *
 * Output:
 *     The program outputs a valid CSV file to stdout which contains the data
 *     to be plotted to a graph in another program such as Microsoft Excel.
 *
 * Compilation:
 *     Use "make". If not possible, try the following:
 *     mpic++ --std=c++11 -O3 -o hopfield main.cpp
 *
 * Author:
 *     Clara Van Nguyen
 */

//C Includes
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mpi.h>

//Our Secret Weapon
#include "hopfield.hpp"

//Default Program Preferences
#define PATTERNS 50
#define NEURONS  100
#define SIM_NUM  50

using namespace std;

int main(int argc, char** argv) {
	//Generic Datatypes
	int patterns, neurons, simulations;
	int size, id;
	double *rbuf1, *rbuf2;

	//MPI Datatypes
	MPI_Datatype t1;

	//Check Parameters
	if (argc != 4) {
		fprintf(stderr, "Usage: %s patterns neurons simulations\n", argv[0]);
		return 1;
	}

	//MPI Configuration
	MPI_Init(NULL, NULL);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &id  );

	//Construct the MPI_Vector
	MPI_Type_vector(patterns, 1, 1, MPI_DOUBLE, &t1);
	MPI_Type_commit(&t1);

	//Parse Parameters
	patterns    = atoi(argv[1]);
	neurons     = atoi(argv[2]);
	simulations = atoi(argv[3]);

	//Set up the random number generator
	srand(time(NULL) * getpid());

	//Setup Average variables.
	vector<signed char> choices = {-1, 1};
	vector<double     > avg_unstable(patterns, 0.0);
	vector<double     > avg_stableIm(patterns, 0.0);
	vector<double     > tmp_cpy     (patterns, 0.0);

	for (int i = id; i < simulations; i += size) {
		//Perform magic
		hopfield<signed char> hnet(patterns, neurons, choices);
		hnet.run_test(i, simulations);

		//Add to averages
		for (int j = 0; j < patterns; j++) {
			avg_unstable[j] += hnet.unstable_prob()[j];
			avg_stableIm[j] += hnet.stable_count ()[j];
		}
	}

	MPI_Barrier(MPI_COMM_WORLD);

	//Perform a gather on the Totals/Averages
	rbuf1 = (double*) malloc(size * patterns * sizeof(double));
	rbuf2 = (double*) malloc(size * patterns * sizeof(double));

	//Gather the Fraction Unstable Totals
	MPI_Gather(
		&avg_unstable[0], patterns, MPI_DOUBLE, rbuf1,
		patterns, MPI_DOUBLE, 0, MPI_COMM_WORLD
	);

	//Gather Stable Imprint Totals
	MPI_Gather(
		&avg_stableIm[0], patterns, MPI_DOUBLE, rbuf2,
		patterns, MPI_DOUBLE, 0, MPI_COMM_WORLD
	);

	//Total up the information
	if (id == 0) {
		for (int i = 0; i < patterns; i++) {
			for (int j = 1; j < size; j++) {
				avg_unstable[i] += rbuf1[(j * patterns) + i];
				avg_stableIm[i] += rbuf2[(j * patterns) + i];
			}
		}
	}

	//MPI Segment done. We can get rid of the data now.
	free(rbuf1);
	free(rbuf2);

	MPI_Barrier(MPI_COMM_WORLD);

	//If we are the first node, print out the details.
	//Otherwise, let the program terminate on its own.
	if (id == 0) {
		//Form CSV File
		//Header
		printf(
			"\"%s\",\"%s\",\"%s\"\n",
			"p",
			"Fraction of Unstable Imprints",
			"Stable Imprints"
		);

		//The rows
		for (int j = 0; j < patterns; j++) {
			avg_unstable[j] /= simulations;
			avg_stableIm[j] /= simulations;
			printf(
				"%d,%lg,%lg\n",
				j,
				avg_unstable[j],
				avg_stableIm[j]
			);
		}
	}

	MPI_Finalize();

	//Save the day
	return 0;
}
