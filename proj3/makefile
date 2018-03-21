CC     = g++
CFLAGS = --std=c++11 -O3
SRCDIR = src

all: hopfield

hopfield: $(SRCDIR)/main.cpp $(SRCDIR)/hopfield.cpp $(SRCDIR)/hopfield.hpp
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) hopfield
