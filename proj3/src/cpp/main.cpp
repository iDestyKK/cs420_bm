#include <stdio.h>
#include <stdlib.h>

#include <array>
#include "hopfield.hpp"

//Program Preferences
#define PATTERNS 50
#define ELEMENTS 100
#define SIM_NUM  50

using namespace std;

int main() {
	srand(time(NULL));
	//Create the interface.
	vector<signed char> choices = {-1, 1};
	vector<double     > avg_unstable(PATTERNS, 0.0);
	vector<double     > avg_stableIm(PATTERNS, 0.0);

	//Create 50 simulations.
	vector< hopfield<signed char> > hnet;
	hnet.resize(SIM_NUM, hopfield<signed char>(PATTERNS, ELEMENTS, choices));

	for (int i = 0; i < hnet.size(); i++) {
		//Perform magic
		hnet[i].run_test();

		//Add to averages
		for (int j = 0; j < PATTERNS; j++) {
			avg_unstable[j] += hnet[i].unstable_prob()[j];
			avg_stableIm[j] += hnet[i].stable_count ()[j];
		}
	}

	//Form CSV File
	//Header
	printf(
		"\"%s\",\"%s\",\"%s\"\n",
		"Experiment",
		"Stable Imprints",
		"Fraction of Unstable Imprints"
	);

	//The rows
	for (int j = 0; j < PATTERNS; j++) {
		avg_unstable[j] /= SIM_NUM;
		avg_stableIm[j] /= SIM_NUM;
		printf("%d,%lg,%lg\n", j, avg_stableIm[j], avg_unstable[j]);
	}

	//Verification code
	/*vector< vector<signed char> >& REF = hnet.data();
	for (int i = 0; i < REF.size(); i++) {
		for (int j = 0; j < REF[i].size(); j++) {
			printf("%d ", (int)REF[i][j]);
		}
		printf("\n");
	}*/

	/*
	vector< vector<double> >& REF = hnet.weights();
	for (int i = 0; i < REF.size(); i++) {
		for (int j = 0; j < REF[i].size(); j++) {
			printf("%lg ", REF[i][j]);
		}
		printf("\n");
	}*/
}
