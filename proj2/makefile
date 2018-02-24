# C Compiler
CC      = gcc
CFLAGS  = --std=gnu89 -g

# CN_Script Compiler
CNC     = /home/ssmit285/giua_cong_chung/bin/cns
CNFLAGS = 

all: acia
	
acia: acia.c
	$(CC) $(CFLAGS) -o $@ $^

acia.c: acia.cns
	$(CNC) $(CNFLAGS) $^ > $@

clean:
	$(RM) acia acia.c
