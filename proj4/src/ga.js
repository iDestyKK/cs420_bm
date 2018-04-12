/*
 * COSC 420 - Project 4: Generic Algorithms
 *
 * Description (UK):
 *     Does stuff.
 * 
 * Author:
 *     Clara Nguyen
 */

class simulation {
	constructor(argv) {
		//Cast all values into integers
		this.genes                 = parseInt(argv[2]);
		this.population_size       = parseInt(argv[3]);
		this.generations           = parseInt(argv[4]);
		this.mutation_probability  = parseFloat(argv[5]);
		this.crossover_probability = parseFloat(argv[6]);

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
		this.generations.push(this.individuals);

		//Set "individuals[]" to be the "newborn[]", then clear it.
		this.individuals = this.newborn;
		this.newborn = [];
	}
}

class individual {
	constructor() {
		this.genes         = [];
		this.fitness       = 0;
		this.fitness_norm  = 0;
		this.running_total = 0;
		this.parents       = [-1, -1];
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
	if (argc - 2 != 5) {
		console.log("Usage: node ga.js genes population_size generations mutation_probability crossover_probability");
		process.exit(1);
	}
	
	let experiment = new simulation(argv);
	experiment.setup();
	for (let i = 0; i < experiment.G; i++) {
		experiment.calculate_fitness();
		experiment.determine_parents_and_mate();
		console.log(experiment.individuals);
		experiment.set_next_generation();
	}
}

//Call main
main(process.argv.length, process.argv)
