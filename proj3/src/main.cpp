/*
 * COSC 420 - Project 3: Hopfield Network
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
 *     g++ --std=c++11 -O3 -o hopfield main.cpp
 *
 * Author:
 *     Clara Van Nguyen
 */

//C Includes
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

//Our Secret Weapon
#include "hopfield.hpp"

//Default Program Preferences
#define PATTERNS 50
#define NEURONS  100
#define SIM_NUM  50

using namespace std;

int main(int argc, char** argv) {
	int patterns, neurons, simulations;

	//Check Parameters
	if (argc != 4) {
		fprintf(stderr, "Usage: %s patterns neurons simulations\n", argv[0]);
		return 1;
	}

	//Parse Parameters
	patterns    = atoi(argv[1]);
	neurons     = atoi(argv[2]);
	simulations = atoi(argv[3]);

	//Set up the random number generator
	srand(time(NULL) * getpid());

	//Setup Average variables.
	vector< signed char    > choices = {-1, 1};
	vector< double         > avg_unstable(patterns, 0.0);
	vector< double         > avg_stableIm(patterns, 0.0);
	vector< vector<double> > avg_basin(patterns, vector<double>(patterns + 1, 0.0));

	for (int i = 0; i < simulations; i++) {
		//Perform magic
		hopfield<signed char> hnet(patterns, neurons, choices);
		hnet.run_test();

		//Add to averages
		for (int j = 0; j < patterns; j++) {
			avg_unstable[j] += hnet.unstable_prob()[j];
			avg_stableIm[j] += hnet.stable_count ()[j];

			//Grad Exclusive: Add up all basin sizes.
			for (int k = 0; k < patterns + 1; k++)
				avg_basin[j][k] += hnet.basin_sizes()[j][k];
		}
	}

	//Grad Exclusive: Form CSV file for Grad Data.
	//For the sake of simplicity, this will output to stderr. Redirect it.
	//Top line
	fprintf(stderr, "\"Unnormalised\"\n");
	for (int i = 0; i < avg_basin[i].size(); i++)
		fprintf(stderr, "%d,", i);
	fprintf(stderr, "\n");

	//The data matrix (Graph 2 in handout)
	for (int i = 0; i < avg_basin.size(); i++) {
		for (int j = 0; j < avg_basin[i].size(); j++)
			fprintf(stderr, "%lg,", (avg_basin[i][j] / simulations));
		fprintf(stderr, "\n");
	}
	fprintf(stderr, "\n");

	fprintf(stderr, "\"Normalised\"\n");
	for (int i = 0; i < avg_basin[i].size(); i++)
		fprintf(stderr, "%d,", i);
	fprintf(stderr, "\n");

	//The data matrix normalised (Graph 1 in handout)
	for (int i = 0; i < avg_basin.size(); i++) {
		for (int j = 0; j < avg_basin[i].size(); j++)
			fprintf(stderr, "%lg,", (avg_basin[i][j] / simulations) / (i + 1));
		fprintf(stderr, "\n");
	}

	//Form CSV File for Undergrad Data
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

	//Save the day
	return 0;
}
