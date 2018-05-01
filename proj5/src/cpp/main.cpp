/*
 * COSC 420 - Project 5: Particle Swarm Optimisation
 *
 * Description (UK):
 *     Does stuff... I think.
 *
 * Synopsis:
 *     ./pso iterations size particle_num inertia cognition social max_velocity
 *         iterations   - Number of iterations the simulator goes through
 *         size         - Size of the world XxX
 *         particle_num - Number of particles in the simulation
 *         inertia      - 
 *         cognition    - 
 *         social       - 
 *         max_velocity - The max velocity a particle can go
 *
 * Example Usages:
 *     ./pso 20 100 20 1.0 2 2
 * 
 * Author:
 *     Clara Nguyen
 */

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

//Our secret weapon
#include "pso.hpp"

using namespace std;

main(int argc, char** argv) {
	//Check arguments
	if (argc != 8) {
		fprintf(
			stderr,
			"Usage: %s %s\n",
			argv[0],
			"iterations size particles inertia cognition social max_velocity"
		);
		exit(1);
	}
	
	//Alright, let's proceed.
	simulation sim;
	
	//Configure the simulator
	sim.iterations   = atoi  (argv[1]);
	sim.size         = atoi  (argv[2]);
	sim.particle_num = atoi  (argv[3]);
	sim.inertia      = strtod(argv[4], NULL);
	sim.cognition    = strtod(argv[5], NULL);
	sim.social       = strtod(argv[6], NULL);
	sim.max_velocity = strtod(argv[7], NULL);

	//Prepare it.
	sim.prepare();

	//Do an upate
	for (int i = 0; i < sim.iterations; i++)
		sim.update();
}
