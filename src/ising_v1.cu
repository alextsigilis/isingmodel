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


__global__ void kernel( int *X, int* Y, double *w, int k, int n) {

	int row_index = blockIdx.x * blockDim.x + threadIdx.x,
			coll_index = blockIdx.y * blockDim.y + threadIdx.y,
			row_stride = gridDim.x * blockDim.x,
			coll_stride = gridDim.y * blockDim.y;

	while( k > 0) {

		if(row_index == 0 && coll_index == 0) {
			int *tmp = X;
			X = Y;
			Y = tmp;
		}

		for( int i = row_index; i < n; i += row_stride ) {
			for( int j = coll_index; j < n; j += coll_stride) {

				double ws = 0;
				for(int l = -2; l <= 2; l++)
					for(int m = -2; m <= 2; m++)
						ws += weight(l,m) * Xmat(i+l, j+m);

				// Update Y	
				const double acc=1.0e-8;
				int sgn =  (( ws > acc) - (ws < -acc));
				Ymat(i,j) = (Xmat(i,j)*(sgn == 0) + sgn*(sgn!=0));
			}
		}
	
		k--;
		__syncthreads();
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


	
	dim3 N( MAX_BLOCKS, MAX_BLOCKS ),
			 M( MAX_THREADS, MAX_THREADS );
	
	kernel<<<N,M>>>(X,Y,w,k,n);

	
	cudaMemcpy(G, Y, n*n, cudaMemcpyDeviceToHost);

	cudaFree(X); cudaFree(Y), cudaFree(d_w);

	return;

}

