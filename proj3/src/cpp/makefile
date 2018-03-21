CC     = g++
CFLAGS = --std=c++11 -O3

all: hopfield

hopfield: main.cpp hopfield.cpp hopfield.hpp
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) hopfield
