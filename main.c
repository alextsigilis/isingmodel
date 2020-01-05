#include <stdio.h>
#include <stdlib.h>
#include "ising.h"

int *G,n,k;

void print_grid(int *G);

int main ( int argc, char** argv ) {

	n = atoi(argv[1]);
	k = atoi(argv[2]);
	G = (int*)malloc(n*n*sizeof(int));

	double w[5*5] = {0.004,0.016,0.026,0.016,0.004,0.016,0.071,0.117,0.071,0.016,0.026,0.117,0.000,0.117,0.026,0.016,0.071,0.117,0.071,0.016,0.004,0.016,0.026,0.016,0.004};

	for(int i = 0; i < n*n; i++) G[i] = (rand() % 2)? -1 : +1;

	print_grid(G);

	ising(G,w,k,n);

	printf("\n\n");

	print_grid(G);


	return 0;
}


void print_grid(int *G) {
	for(int i = 0; i < n; i++) {
		for(int j = 0; j < n; j++) printf("%c ", (G[i*n+j] == -1)?'-':'+');
		printf("\n");
	}
}
