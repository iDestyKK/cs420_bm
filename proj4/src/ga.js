/*
 * COSC 420 - Project 4: Genetic Algorithms (Node.js Edition)
 *
 * Description (UK):
 *     Simulations a population and how it grows, produces offspring, and
 *     so on. The simulation can span an infinite amount of generations and
 *     support an infinite number of genes and individuals. The goal is to
 *     figure out how to make a population have the most fit individuals.
 *
 * Output:
 *     The output of this simulation is a CSV file which is expected to be
 *     piped to a file. Graphs can be generated to show visually what is
 *     going on in each generation. Microsoft Excel is preferred for the
 *     graph generation.
 * 
 * Synopsis:
 *     node ga.js genes population generations mutation_prob crossover_prob
 *       genes          - Number of genes each individual has
 *       population     - Number of individuals per generation
 *       generations    - Number of generations to go through
 *       mutation_prob  - Probability for a gene to mutate (flip)
 *       crossover_prob - Probability for genes to flip between 2 children
 *
 * Example Usages:
 *     node ga.js 20 30 10 0.033 0.6
 *
 * Author:
 *     Clara Nguyen
 */

"use strict";

class simulation {
	constructor(argv) {
		//Cast all values into integers
		this.genes                 = parseInt(argv[0]);
		this.population_size       = parseInt(argv[1]);
		this.generations           = parseInt(argv[2]);
		this.mutation_probability  = parseFloat(argv[3]);
		this.crossover_probability = parseFloat(argv[4]);

		//Setup variable names
		this.L                     = this.genes;
		this.N                     = this.population_size;
		this.G                     = this.generations;
		this.PM                    = this.mutation_probability;
		this.PC                    = this.crossover_probability;

		//Array of individuals
		this.individuals = [];
		this.newborn     = [];
		this.generations = [];
	}

	setup() {
		//Generate N-bit strings each of size L.
		for (let i = 0; i < this.N; i++) {
			this.individuals.push(
				new individual()
			);

			//Randomise the string
			for (let j = 0; j < this.L; j++) {
				if (Math.floor(Math.random() * 2) == 1)
					this.individuals[i].genes.push(1);
				else
					this.individuals[i].genes.push(0);
			}
		}
	}

	calculate_fitness() {
		let total  = 0.0;
		let ntotal = 0.0;

		//Compute the fitness of all nodes
		for (let i = 0; i < this.individuals.length; i++)
			total += this.individuals[i].calc_F(this.L);

		//Normalise them all
		for (let i = 0; i < this.individuals.length; i++) {
			this.individuals[i].fitness_norm = this.individuals[i].fitness / total;
			ntotal += this.individuals[i].fitness_norm;
			this.individuals[i].running_total = ntotal;
		}
	}

	determine_parents_and_mate() {
		for (let j = 0; j < this.N / 2; j++) {
			//Choose 2 random numbers between 0 and 1.
			let r1 = Math.random(),
				r2;
			let p1, p2, c1, c2;
			let crossover = Math.random();

			//Find Parent 1
			for (let i = 0; i < this.individuals.length; i++) {
				if (this.individuals[i].running_total > r1) {
					p1 = i;
					break;
				}
			}
			p2 = p1;

			//Find Parent 2
			while (p1 == p2) {
				r2 = Math.random();
				for (let i = 0; i < this.individuals.length; i++) {
					if (this.individuals[i].running_total > r2) {
						p2 = i;
						break;
					}
				}
			}

			//Make 2 children.
			this.newborn.push(
				new individual(),
				new individual()
			);
			c1 = this.newborn.length - 2;
			c2 = c1 + 1;

			//First one gets genes from parent 1.
			this.newborn[c1].genes = this.individuals[p1].genes.slice();
			this.newborn[c1].parents = [
				this.individuals[p1],
				this.individuals[p2]
			];

			//Second one gets genes from parent 2.
			this.newborn[c2].genes = this.individuals[p2].genes.slice();
			this.newborn[c2].parents = [
				this.individuals[p1],
				this.individuals[p2]
			];

			//Choose a random number to determine if they crossover.
			if (crossover < this.PC) {
				//We will crossover the genes at "mix_at".
				let mix_at = Math.floor(Math.random() * this.L);
				for (let k = mix_at; k < this.L; k++) {
					this.newborn[c1].genes[k] = this.individuals[p2].genes[k];
					this.newborn[c2].genes[k] = this.individuals[p1].genes[k];
				}
			}
		}

		//Perform any mutations on the offspring.
		for (let i = 0; i < this.newborn.length; i++) {
			for (let j = 0; j < this.newborn[i].genes.length; j++) {

				//If the number chosen is lower than PM, flip the bit.
				if (Math.random() < this.PM) {
					this.newborn[i].genes[j] = +!this.newborn[i].genes[j];
				}
			}
		}
	}

	set_next_generation() {
		//Push "individuals[]" into "generations[]".
		//Make it an object that we can analyse later on.
		this.generations.push(
			new generation(this.individuals)
		);

		this.generations[this.generations.length - 1].compute_values();

		//Set "individuals[]" to be the "newborn[]", then clear it.
		this.individuals = this.newborn;
		this.newborn = [];
	}
}

class generation {
	constructor(arr) {
		this.individuals      = arr;
		this.avg_fitness      = undefined;
		this.fitness_best     = undefined;
		this.avg_correct_bits = undefined;
	}

	compute_values() {
		//Assume that the first individual has the best fitness
		this.fitness_best     = this.individuals[0].fitness;
		this.avg_fitness      = 0.0;
		this.avg_correct_bits = 0.0;

		//Compute Average Fitness, Best Fitness, and Average of "Correct" bits
		for (let i = 0; i < this.individuals.length; i++) {
			this.avg_fitness += this.individuals[i].fitness;

			//Set the best fitness if available.
			if (this.individuals[i].fitness > this.fitness_best)
				this.fitness_best = this.individuals[i].fitness;

			//Add number of correct bits
			for (let j = 0; j < this.individuals[i].genes.length; j++) {
				this.avg_correct_bits += this.individuals[i].genes[j];
			}
		}
		this.avg_fitness      /= this.individuals.length;
		this.avg_correct_bits /= this.individuals.length;
	}
}

class individual {
	constructor() {
		this.genes         = [];
		this.fitness       = 0;
		this.fitness_norm  = 0;
		this.running_total = 0;
		this.parents       = [undefined, undefined];
	}

	calc_F(L) {
		this.fitness = Math.pow(bitarray_to_int(this.genes) / Math.pow(2, L), 10);
		return this.fitness;
	}
}

function bitarray_to_int(str) {
	/* Converts a string of binary numbers into its respective integers */
	var res = 0;
	for (let i = 0; i < str.length; i++)
		res += (1 << i) * (str[str.length - 1 - i] == 1);
	return res;
}

function main(argc, argv) {
	//You did it wrong.
	if (argc - 2 != 5) {
		console.log("Usage: node ga.js genes population generations mutation_prob crossover_prob");
		process.exit(1);
	}
	
	//Run the Simulation
	let experiment = new simulation(argv.slice(2));
	experiment.setup();
	for (let i = 0; i < experiment.G; i++) {
		experiment.calculate_fitness();
		experiment.determine_parents_and_mate();
		experiment.set_next_generation();
	}
	
	//Print out the CSV file
	console.log("\"Generation\",\"Average Fitness\",\"Best Fitness Individual\",\"Average Correct Bits\"");
	for (let i = 0; i < experiment.generations.length; i++) {
		let _GEN = experiment.generations[i];

		console.log(
			"%d,%d,%d,%d",
			i,
			_GEN.avg_fitness,
			_GEN.fitness_best,
			_GEN.avg_correct_bits
		);
	}
}

//Call main
main(process.argv.length, process.argv)
