#ifndef __ISINGMODEL_H__
#define __ISINGMODEL_H__


#ifndef __device__
#define __device__
#endif

//! Ising model evolution
/*!
	\param G			Spins on the square lattice							[n-by-n]
	\param w			Weight matrix														[5-by-5]
	\param k			number of iterations										[scalar]
	\param n			Number of latice points per dim					[scalar]

	NOTE: Both matrices G and w are stored in row-major orlder

*/
void ising( int* G, double* w, int k, int n);


//! Swap the pointer to 2 matrices
/*!
	\param G		Pointer to the first array	pointer			[pointer]
	\param H		Pointer to the second array pointer			[pointer]
*/
static inline void swap_mat(int **G, int **H);


//! Calculates the signum function.
/*!
	\param d		The input to sgn(d)			[scalar]
	
	\return	[int] -1 if d is negative, 1 if d is possitive, 0 if d is 0
*/
__device__ static inline int sgn (double d);


//! Calculate the new spin value based on the old value and the weighted sum of the neighbors
/*!
	\param old_value			The spin in the pervious "time"										[scalar]
	\param ws							The weighted sum of the values of the neighbors		[scalar]

	\return [int] the new value for the spin
*/
__device__ static inline int update(int old_value, double ws);

#endif /* __ISINGMODEL_H__ */
