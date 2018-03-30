# C Compiler
CC      = gcc
CFLAGS  = --std=gnu89 -g -O3 -lm

# CN_Script Compiler
CNC     = /home/ssmit285/giua_cong_chung/bin/cns
CNFLAGS = 

all: aica
	
aica: aica.c
	$(CC) $(CFLAGS) -o $@ $^

aica.c: aica.cns
	$(CNC) $(CNFLAGS) $^ > $@

clean:
	$(RM) aica aica.c
