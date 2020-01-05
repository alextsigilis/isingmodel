all: v0

v0: main.c src/ising_v0.c
	gcc -Iinc/ -o lib/ising_v0.o -c src/ising_v0.c
	gcc -Iinc/ -o main_v0 lib/ising_v0.o main.c
	

v1: main.c src/ising_v1.cu
	cp main.c main.cu
	nvcc  -Iinc/ -o lib/ising_v1.o -c src/ising_v1.cu
	nvcc  -Iinc/ -o main_v1 lib/ising_v1.o main.cu
	rm main.cu	


clean:
	rm -rf lib/*.o main_* *.dSYM
