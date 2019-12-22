CC = clang

CFLAGS = -O0 -Wall -g

main = main.c

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

sequential: ising_v0.a $(main)
	$(CC) $(CFLAGS) -o sequential $(main) $<
	rm -rf $< *.dSYM

ising_v0.a: ising_v0.o
	ar rcs $@ $<
	rm $<

ising_v0.o: ising_v0.c
	$(CC) $(CFLAGS)  -o $@ -c $<


clean:
	rm -rf *.a *.o sequential *.dSYM


