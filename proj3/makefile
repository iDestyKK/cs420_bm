CC     = g++
CFLAGS = --std=c++11 -O3
SRCDIR = src

MPICC  = mpic++
MPIFL  = --std=c++11 -O3
MPIDIR = src/mpi_ver

all: hopfield hopfield_mpi

hopfield: $(SRCDIR)/main.cpp $(SRCDIR)/hopfield.cpp $(SRCDIR)/hopfield.hpp
	$(CC) $(CFLAGS) -o $@ $<

hopfield_mpi: $(MPIDIR)/main.cpp $(MPIDIR)/hopfield.cpp $(MPIDIR)/hopfield.hpp
	$(MPICC) $(MPIFL) -o $@ $<

clean:
	$(RM) hopfield hopfield_mpi
