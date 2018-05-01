//C Stuff
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//C++ stuff
#include <iostream>
#include <string>
#include <functional>
#include <algorithm>
#include <vector>

using namespace std;

//Some helper functions
namespace skills {
	double random_double(double, double);
	double fsqr(double);
}

//Structs/Classes
struct vec2 {
	vec2();
	vec2(double, double);
	double x, y;
};

struct particle {
	particle();
	vec2 pos;
	vec2 velocity;
	vec2 personal_best;
};

struct simulation {
	//Constructors
	simulation();

	//Functions
	void prepare();
	void update();
	
	//Parametrs
	int iterations, size, particle_num;
	double inertia, cognition, social, max_velocity;

	//Our cool stuff
	vec2 p1, p2;
	vector<particle> obj;
	vec2 global_best;
};
