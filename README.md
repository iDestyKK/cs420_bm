# CS420 - Biologically-Inspired Computation

## Synopsis
COSC 420, 427, and 527 focus on *biologically-inspired computation*, including
recent developments in computational methods inspired by nature, such as neural
networks, genetic algorithms and other evolutionary computation systems, ant
swarm optimization, artificial immune systems, swarm intelligence, cellular
automata, and multi-agent systems.

## Projects Progression
```diff
+ Project 1 - 1D Cellular Automata (Done!)
+ Project 2 - Activation/Inhibition Cellular Automaton (Done!)
+ Project 3 - Hopfield Net (Done!)
+ Project 4 - Genetic Algorithms (Done!)
+ Project 5 - Particle Swarm Optimization (Done!)
- Project 6 - Extra Credit (N/A)
```

## Programming Languages Used
Each project is written in a different language. This was a challenge I posed
to show that these projects are not restrained to a single programming
language. However, a lot of them are very similar (i.e., Node.js is an
improvement over regular Javascript, and CN\_Script succeeds C).

* **Project 1** - Java (simulator given to us)
* **Project 2** - CN\_Script 0.0.1
* **Project 3** - C++ (w/ OpenMPI)
* **Project 4** - Node.js
* **Project 5** - Multiple Implementations:
  * C++
  * GML (Game Maker Language)
  * HTML/JS/CSS w/ WebGL

Initially, I planned to use languages such as CoffeeScript, Python, and C#. But
these languages, unfortunately, did not make it into the list of implementations
this semester.

## Project Directory Structure and Contents
Each project is generally presented in the following directory structure:
```
bin         - Pre-compiled executables (Windows usually)

doc         - Original Master Files used to create reports.

experiments - Data (commonly in xlsx or csv) generated by the simulations.

scr         - Scripts used to aid in the project. These may include automation
              of experiments, or other tedious tasks.

src         - Source code of the simulator. If there are multiple
              implementations, then they are separated by directory.

submit      - Contains files in my original assignment submission.

writeup     - A copy of the original project writeup.
```
Each project directory also has a PDF master of my report for each project, as
well as a `makefile` and `run.sh` (if possible). Some of the languages used, like
Node.js do not require compliation. Projects that use interpreted languages do
not feature a makefile.
