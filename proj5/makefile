CC     = g++
CFLAGS = -g --std=c++11

all: pso

pso: src/cpp/main.cpp src/cpp/pso.cpp
	$(CC) $(CFLAGS) -o $@ $^

clean:
	$(RM) pso
