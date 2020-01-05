# The Shell you're using
SHELL := /bin/bash

# The C compiler
CC = clang

# Flags for the gcc
CFLAGS = -O3 -Wall -g

# Include paths for header files
INC = -Iinc/ 

# Paths for libriries to link
LDFLAGS = 

# Libraries to load
LIBS = -lm

# -----=-------=--------=-----=-------=-----=

TYPES = v0

SRC = ising

MAIN = main

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all: $(addprefix $(MAIN)_, $(TYPES))

$(MAIN)_%: $(MAIN).c lib/$(SRC)_%.a
	$(CC) $(CFLAGS) $(INC) -o $@ $^ $(LDFLAGS) $(LIBS)
	rm -rf *.dSYM

lib: $(addsuffix .a, $(addprefix lib/$(SRC)_, $(TYPES)))


lib/%.a: lib/%.o
	ar rcs $@ $<
	rm $<

lib/%.o: src/%.c
	$(CC) $(CFLAGS) $(INC) -o $@ -c $<

clean:
	rm -rf *.dSYM lib/*.a *~ $(addprefix $(MAIN)_, $(TYPES))
