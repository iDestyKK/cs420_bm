#ifndef __HOPFIELD_TPP_CPP_HAN__
#define __HOPFIELD_TPP_CPP_HAN__

#include <stdio.h>
#include <stdlib.h>
#include "hopfield.hpp"

#define TM \
	template <typename T>

#define DEBUG_PRINT 0

using namespace std;

//Constructor Methods
TM hopfield<T>::hopfield() {

}

TM hopfield<T>::hopfield(unsigned int i, unsigned int j) {
	//Set default values
	p.resize(i, vector<T     >(j, 0  ));
	w.resize(j, vector<double>(j, 0.0));
	n.resize(j, 0.0);
	
	//Set the number of stable instances to 0
	num_stable.resize(i, 0);

	//Also statistical stuff
	prob_stable  .resize(i, 0.0);
	prob_unstable.resize(i, 0.0);
}

TM hopfield<T>::hopfield(unsigned int i, unsigned int j, const vector<T>& c) {
	//Set default values
	p.resize(i, vector<T     >(j, 0  ));
	w.resize(j, vector<double>(j, 0.0));
	n.resize(j, 0.0);

	//Set the number of stable instances to 0
	num_stable.resize(i, 0);

	//Also statistical stuff
	prob_stable  .resize(i, 0.0);
	prob_unstable.resize(i, 0.0);

	//Shuffle the values around
	permeate(c);
}

//Get Methods
TM unsigned int hopfield<T>::neurons() {
	return p[0].size();
}

TM unsigned int hopfield<T>::patterns() {
	return p.size();
}

TM vector< vector<T> >& hopfield<T>::data() {
	return p;
}

TM vector< vector<double> >& hopfield<T>::weights() {
	return w;
}

TM vector<double>& hopfield<T>::net() {
	return n;
}

TM vector<double>& hopfield<T>::stable_prob() {
	return prob_stable;
}

TM vector<double>& hopfield<T>::unstable_prob() {
	return prob_unstable;
}

TM vector<int>& hopfield<T>::stable_count() {
	return num_stable;
}

//"Do some stuff" Functions
TM void hopfield<T>::permeate(const vector<T>& c) {
	//Goes through all of the "patterns" and fills it with values from the
	//"choices" vector at random. This means you can fill that vector with a lot
	//of values and it will just randomly choose from it.
	
	//Let's use some C++ 11 tricks. std::generate looks like a wonderful one.
	for (int i = 0; i < p.size(); i++)
		std::generate(p[i].begin(), p[i].end(), [=](){ return c[rand() % c.size()];});
}

TM void hopfield<T>::calc_w(int k) {
	/*
		Uses the following equation:
		w_ij = {
			if i != j -> 1/N SIG^P_{k=1}{S_{i}S_{j}}
			if i == j -> 0
		}
	*/

	for (int i = 0; i < neurons(); i++) {
		for (int j = 0; j < neurons(); j++) {
			if (i != j) {
				//The true formula involves 1/N. However, for now, we will just
				//get a total, then do the division in "stable_test".
				w[i][j] += p[k][i] * p[k][j];
			}
		}
	}
}

TM bool hopfield<T>::is_stable(int k) {
	vector<T>      network = p[k];
	double         total;
	signed char    new_state;

	for (int i = 0; i < network.size(); i++) {
		//Compute "h".
		total = 0.0;
		for (int j = 0; j < network.size(); j++)
			total += (w[i][j] / neurons()) * p[k][j];

		//Determine the new state
		new_state = (total < 0) ? -1 : 1;

		if (network[i] != new_state) {
			//"If any of the 100 elements of the neural net differ from its
			//corresponding new state value, then the imprinted pattern that
			//was assigned to the neural net is NOT stable."
			return false;
		}
	}

	//Guaranteed to be stable
	return true;
}

TM void hopfield<T>::run_test(int sn = -1, int st = -1) {
	bool stable;

	//Set the simulation number
	sim_num   = sn;
	sim_total = st;

	if (sim_num != -1 && DEBUG_PRINT)
		printf("\rSimulation %d...", sim_num);

	for (int i = 0; i < p.size(); i++) {
		calc_w(i);
		if (sim_num != -1 && DEBUG_PRINT) {
			printf(
				"\rSimulation %d... %lg\%",
				sim_num,
				(100.0 * ((double)i / p.size()) / sim_total) + (100 / sim_total) * sn
			);
		}

		num_stable[i] = 0;
		for (int j = 0; j <= i; j++) {
			if (sim_num != -1 && DEBUG_PRINT) {
				printf(
					"\rSimulation %d... %lg\%",
					sim_num,
					(
						(100.0 * ((double)i / p.size()) / sim_total) +
						((100 / sim_total) * sn                    ) + 
						(((double)j / i) / sim_total / p.size()    ) + 
						((double)i / p.size() / sim_total          )
					)
				);
			}

			if (is_stable(j)) {
				num_stable[i]++;
			}
		}

		prob_stable  [i] = static_cast<double>(num_stable[i]) / (i + 1);
		prob_unstable[i] = 1.0 - prob_stable[i];
	}
}

#endif
