#include<stdio.h>
typedef char literal[256];
void main(void) {
	/*----Variaveis temporarias----*/
	int t0;
	int t1;
	int t2;
	int t3;
	int t4;
	/*------------------------------*/
	literal A;
	int B;
	int D;
	double C;
	
	
	
	printf("Digite B");
	scanf("%d", &B);
	printf("Digite A:");
	scanf("%s", A);
	t0 = B > 2;
	if(t0) {
		t1 = B <= 4;
		if(t1) {
			printf("B esta entre 2 e 4");
		}
	}
	t2 = B + 1;
	B = t2;
	t3 = B + 2;
	B = t3;
	t4 = B + 3;
	B = t4;
	D = B;
	C = 5.0;
	printf("\nB=\n");
	printf("%d", D);
	printf("\n");
	printf("%lf", C);
	printf("\n");
	printf("%s", A);
	
	return 0;
}
