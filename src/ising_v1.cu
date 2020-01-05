#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "ising.h"

#define		MAX_THREADS			32
#define		MAX_BLOCKS			256

#define			idx(i,j)				((n+i)%n)*n + (n+j)%n
#define 		Xmat(i,j)				X[ idx(i,j) ]
#define			Ymat(i,j)				Y[ idx(i,j) ]
#define			weight(i,j)			w[ (2+i)*5 + (2+j) ]


__global__ void kernel( int *X, int* Y, double *w, int n) {

	int row_index = blockIdx.x * blockDim.x + threadIdx.x,
			coll_index = blockIdx.y * blockDim.y + threadIdx.y,
			row_stride = gridDim.x * blockDim.x,
			coll_stride = gridDim.y * blockDim.y;


			for( int i = row_index; i < n; i += row_stride ) {
				for( int j = coll_index; j < n; j += coll_stride) {

					double ws = 0;
					for(int l = -2; l <= 2; l++)
						for(int m = -2; m <= 2; m++)
							ws += weight(l,m) * Xmat(i+l, j+m);

					Ymat(i,j) = update(Xmat(i,j), ws);

				}
			}
}

void ising(int* G, double* w, int k, int n) {

	int *X, *Y;
	double *d_w;

	cudaMalloc(&X, n*n);
	cudaMalloc(&Y, n*n);
	cudaMalloc(&d_w, 5*5);

	cudaMemcpy(Y,G, n*n, cudaMemcpyHostToDevice);
	cudaMemcpy(d_w, w, 5*5, cudaMemcpyHostToDevice);

	while( k > 0) {

		swap_mat( &X, &Y );
	
		dim3 N( MAX_BLOCKS, MAX_BLOCKS ),
				 M( MAX_THREADS, MAX_THREADS );
	
		kernel<<<N,M>>>(X,Y,w,n);

		k--;
	}

	cudaMemcpy(G, Y, n*n, cudaMemcpyDeviceToHost);

	cudaFree(X); cudaFree(Y), cudaFree(d_w);

	return;

}


__device__ static inline int update(int old_value, double ws) {

	int sign = sgn(ws);

	return (old_value*(sign == 0) + sign*(sign!=0));

}

static void swap_mat(int **G, int **H) {

	int *tmp = *H;
	*H = *G;
	*G = tmp;


}

static inline int sgn (double d){

	const double acc=1.0e-8;

	return (( d > acc) - (d < -acc));
}
