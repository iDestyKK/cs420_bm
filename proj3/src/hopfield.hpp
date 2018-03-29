#ifndef __HOPFIELD_HPP_CPP_HAN__
#define __HOPFIELD_HPP_CPP_HAN__

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <algorithm>

using namespace std;

template <typename T>
class hopfield {
	public:
		//Constructor Methods
		hopfield();

		//We want to make the interface as nice as possible
		hopfield(unsigned int, unsigned int);
		hopfield(unsigned int, unsigned int, const vector<T>&);

		//Get Functions
		unsigned int              neurons       ();
		unsigned int              patterns      ();
		vector< vector<T     > >& data          ();
		vector< vector<double> >& weights       ();
		vector< double         >& net           ();
		vector< double         >& stable_prob   ();
		vector< double         >& unstable_prob ();
		vector< int            >& stable_count  ();
		vector< vector<double> >& basin_sizes   ();

		//"Do some stuff" Functions
		void                      permeate      (const vector<T>&);
		void                      calc_w        (int);
		int                       calc_b        (int); //Grad Exclusive!
		bool                      is_stable     (int);
		void                      run_test      ();
	private:
		vector< vector<T     > >  p;             //Patterns
		vector< vector<double> >  w;             //Weights
		vector< double         >  n;             //Neural Net
		vector< int            >  num_stable;    //Self-Explanatory
		vector< double         >  prob_stable;   //Ditto
		vector< double         >  prob_unstable; //Ditto...
		vector< vector<double> >  basin_size;    //DITTO...
};

#include "hopfield.cpp"

#endif
