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

	int stride = gridDim.y * blockDim.y,
			i = threadIdx.x + blockIdx.x * blockDim.x,
			j = threadIdx.y + blockIdx.y * blockDim.y;

	
	for(; i < n; i += stride ) {
		for(; j < n; j += stride ) {

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

	cudaMalloc(&X, n*n*sizeof(int));
	cudaMalloc(&Y, n*n*sizeof(int));
	cudaMalloc(&d_w, 5*5*sizeof(double));

	cudaMemcpy(d_w, w, 5*5*sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy(Y, G, n*n*sizeof(int), cudaMemcpyHostToDevice);

	dim3 N(BLOCK,BLOCK),
			 M(THREAD,THREAD);

	while(k > 0) {
		
		swap_mat( &X, &Y );

		kernel<<<N,M>>>(Y,X,d_w,k,n);

		cudaDeviceSynchronize();

		k--;
	}

	cudaMemcpy(G, Y, n*n*sizeof(int), cudaMemcpyDeviceToHost);

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
