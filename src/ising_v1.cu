#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "ising.h"

#define			BLOCK						256
#define			THREAD					32

#define			idx(i,j)				((n+i)%n)*n + (n+j)%n
#define 		Xmat(i,j)				X[ idx(i,j) ]
#define			Ymat(i,j)				Y[ idx(i,j) ]
#define			weight(i,j)			w[ (2+i)*5 + (2+j) ]


__global__ void kernel(int* Y, int *X, double *w, int k, int n) {

	int row_index = blockIdx.x * blockDim.x + threadIdx.x,
			coll_index = blockIdx.y * blockDim.y + threadIdx.y,
			row_stride = gridDim.x * blockDim.x,
			coll_stride = gridDim.y * blockDim.y;


	for(int i = row_index; i < n; i += row_stride) {
		for(int j = coll_index; j < n; j += coll_stride) {

			double ws = 0;
			for(int l = -2; l <= 2; l++)
				for(int m = -2; m <= 2; m++)
					ws += weight(l,m) * Xmat(i+l, j+m);

			Ymat(i,j) = update(Xmat(i,j), ws);	

		}
	}	

}

__host__ void ising(int* G, double* w, int k, int n) {

	int *X, *Y;
	double *d_w;

	cudaMallocManaged(&X, n*n);
	cudaMallocManaged(&Y, n*n);
	cudaMallocManaged(&d_w, 5*5);

	for(int i = 0; i < 5*5; i++) d_w[i] = w[i];
	for(int i = 0; i < n*n; i++) Y[i] = G[i];

	dim3 N(BLOCK,BLOCK),
			 M(THREAD,THREAD);


	while(k > 0) {
		
		swap_mat( &X, &Y );

		kernel<<<N,M>>>(Y,X,d_w,k,n);

		cudaDeviceSynchronize();

		k--;
	}

	for(int i = 0; i < n*n; i++) G[i] = Y[i];

	cudaFree(X); cudaFree(Y);
	cudaFree(d_w);

	return;

}


__device__ int update(int old_value, double ws) {

	int sign = sgn(ws);

	return (old_value*(sign == 0) + sign*(sign!=0));

}

static void swap_mat(int **G, int **H) {

	int *tmp = *H;
	*H = *G;
	*G = tmp;


}

__device__ int sgn (double d){

	const double acc=1.0e-8;

	return (( d > acc) - (d < -acc));
}
