#include <stdio.h>
#include <stdlib.h>
#include "ising.h"

//void print_grid(int *G);

int main ( int argc, char** argv ) {

	FILE *fin;

	int n = 517,
			k = atoi(argv[1]),
			*G_init = (int*)malloc(n*n*sizeof(int)),
			*G_fin = (int*)malloc(n*n*sizeof(int));

	double w[5*5] = {0.004,0.016,0.026,0.016,0.004,0.016,0.071,0.117,0.071,0.016,0.026,0.117,0.000,0.117,0.026,0.016,0.071,0.117,0.071,0.016,0.004,0.016,0.026,0.016,0.004};

	
	fin = fopen("conf-init.bin", "rb");
	fread(G_init, sizeof(int), n*n, fin);
	fclose(fin);

	switch(k) {
		case 1:
			fin = fopen("conf-1.bin", "rb");
			break;
		case 4:
			fin = fopen("conf-4.bin", "rb");
			break;
		case 11:
			fin = fopen("conf-11.bin", "rb");
			break;
		default:
			k = 1;
			printf("Running for k = 1 ....");
			fin = fopen("conf-1.bin", "rb");
			break;
	}

	fread(G_fin, sizeof(int), n*n, fin);
	fclose(fin);

	ising(G_init, w, k, n);

	for(int i = 0; i < n*n; i++)
		if(G_init[i] != G_fin[i]) {
			printf("WRONG\n");
			return 0;
		}

	printf("CORRECT\n");

	return 0;
}


/*void print_grid(int *G) {
	for(int i = 0; i < n; i++) {
		for(int j = 0; j < n; j++) printf("%c ", (G[i*n+j] == -1)?'-':'+');
		printf("\n");
	}
}*/
