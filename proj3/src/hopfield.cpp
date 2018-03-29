#ifndef __HOPFIELD_TPP_CPP_HAN__
#define __HOPFIELD_TPP_CPP_HAN__

#include <stdio.h>
#include <stdlib.h>
#include "hopfield.hpp"

#define TM \
	template <typename T>

#define MIN(X, Y) \
	(((X) < (Y)) ? (X) : (Y))

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

	//Grad Exclusive: Include Basin Size
	basin_size.resize(i, vector<double>(i + 1, 0.0));
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

	//Grad Exclusive: Include Basin Size
	basin_size.resize(i, vector<double>(i + 1, 0.0));

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

TM vector< vector<double> >& hopfield<T>::basin_sizes() {
	return basin_size;
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

TM int hopfield<T>::calc_b(int k) {
	//Grad Exclusive!
	//Computes the basin size.
	
	//Make a network of neurons. Base it off of pattern "k" and modify it.
	vector<T> network;
	double total   = 0.0;
	bool converges;
	int ii, i, j, x, y;

	//Return values
	double basin_avg = 0.0;

	for (ii = 0; ii < 10; ii++) {
		//Create a bit flip vector thing that we can use to determine number of bits
		//to flip until the network does not converge to that pattern.
		vector<int > bit_id (neurons());
		vector<bool> bit_chk(neurons(), false);
		size_t sel;
		
		//Fill it up with values. Though let's shuffle it up a bit.
		//TODO: Implement Fisher-Yates or use std::random_shuffle()
		for (i = 0; i < neurons(); i++) {
			do {
				sel = rand() % neurons();
			} while (bit_chk[sel] == true);

			bit_chk[sel] = true;
			bit_id [sel] = i;
		}

		//Get the current pattern k
		network = p[k];

		//Go through the first "P" elements in bit_id and flip bits.
		for (i = 0; i < patterns(); i++) {
			//Flip
			network[bit_id[i]] = (network[bit_id[i]] == 1) ? -1 : 1;
			converges          = false;

			vector<T> tamper_network = network;

			//Now let's update that network and see if, after 10 iterations, it has
			//converged back into the original pattern p[k]... behold.
			for (j = 0; j < 10; j++) {
				//Essentially the same as "is_stable", except we actually do change
				//some values.
				for (x = 0; x < tamper_network.size(); x++) {
					//Compute "h".
					total = 0.0;
					for (y = 0; y < tamper_network.size(); y++)
						total += (w[x][y] / neurons()) * tamper_network[y];
					
					//Update the network.
					tamper_network[x] = (total < 0) ? -1 : 1;
				}

				//if (std::equal(network.begin(), network.begin() + network.size(), p[k].begin())) {
				if (tamper_network == p[k]) {
					converges = true;
					break;
				}
			}

			//"The first iteration of the permutation array (as given by j) where the
			//network does not converge to the current imprinted pattern k is the
			//number that estimates the size of the basin of attraction for that
			//imprinted pattern."
			if (!converges)
				break;
		}

		basin_avg += (i + ((i == patterns()) ? 0 : 1));
	}

	return static_cast<int>(basin_avg / 10);
}

TM bool hopfield<T>::is_stable(int k) {
	//Determines whether or not a pattern is stable.
	//Generate new patterns, and if they all match the current ones in the network
	//then the pattern is stable. Otherwise, it isn't.
	vector<T>      network = p[k];
	vector<double> h(network.size(), 0.0);
	double         total;
	signed char    new_state;

	for (int i = 0; i < network.size(); i++) {
		//Compute "h".
		total = 0.0;
		for (int j = 0; j < network.size(); j++)
			//h[j] = (w[i][j] / neurons()) * p[k][j];
			total += (w[i][j] / neurons()) * p[k][j];

		//Accumulate the data.
		//total = std::accumulate(h.begin(), h.end(), 0.0);

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

TM void hopfield<T>::run_test() {
	bool stable;
	int b;

	for (int i = 0; i < p.size(); i++) {
		calc_w(i);

		num_stable[i] = 0;
		for (int j = 0; j <= i; j++) {
			if (is_stable(j)) {
				num_stable[i]++;

				//Grad Exclusive: Update the Basin Size Histogram
				b = MIN(calc_b(i), p.size());
				basin_size[i][b]++;
			}
			else {
				//Grad Exclusive: Update the 0 index.
				basin_size[i][0]++;
			}
		}

		prob_stable  [i] = static_cast<double>(num_stable[i]) / (i + 1);
		prob_unstable[i] = 1.0 - prob_stable[i];
	}
}

#endif
