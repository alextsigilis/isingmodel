all: v0 v1 v2

v0: main.c src/ising_v0.c
	gcc -Iinc/ -o lib/ising_v0.o -c src/ising_v0.c
	gcc -Iinc/ -o main_v0 lib/ising_v0.o main.c
	

v1: main.c src/ising_v1.cu
	cp main.c main.cu
	nvcc  -Iinc/ -o lib/ising_v1.o -c src/ising_v1.cu
	nvcc  -Iinc/ -o main_v1 lib/ising_v1.o main.cu
	rm main.cu	

v2: main.c src/ising_v2.cu
	cp main.c main.cu
	nvcc  -Iinc/ -o lib/ising_v2.o -c src/ising_v2.cu
	nvcc  -Iinc/ -o main_v2 lib/ising_v2.o main.cu
	rm main.cu	


clean:
	rm -rf lib/*.o main_* *.dSYM
