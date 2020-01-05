#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "ising.h"


#define			idx(i,j)				((n+i)%n)*n + (n+j)%n
#define 		Xmat(i,j)				X[ idx(i,j) ]
#define			Ymat(i,j)				Y[ idx(i,j) ]
#define			weight(i,j)			w[ (2+i)*5 + (2+j) ]

void ising(int* G, double* w, int k, int n) {

	int *X = malloc(n*n*sizeof(int)),
			*Y = malloc(n*n*sizeof(int));

	for(int i = 0; i < n*n; i++) Y[i] = G[i];

	while( k > 0) {

		swap_mat( &X, &Y );

		for(int i = 0; i < n; i++) {
			for(int j = 0; j < n; j++) {

				double ws = 0;
				for(int l = -2; l <= 2; l++)
					for(int m = -2; m <= 2; m++)
						ws += weight(l,m) * Xmat(i+l, j+m);

				Ymat(i,j) = update(Xmat(i,j), ws);
			}
		}
		k--;
	}

	for(int i = 0; i < n*n; i++) G[i] = Y[i];

	free(X); free(Y);

	return;

}


static inline int update(int old_value, double ws) {

	int sign = sgn(ws);

	return (old_value*(sign == 0) + sign*(sign!=0));

}

static void swap_mat(int **G, int **H) {

	int *tmp = *H;
	*H = *G;
	*G = tmp;


}

int sgn (double d){

	const double acc=1.0e-8;

	return (( d > acc) - (d < -acc));
}
