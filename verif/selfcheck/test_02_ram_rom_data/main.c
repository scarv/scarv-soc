
#include "selfcheck.h"

#define ALEN 20

int   arry_a [ALEN];
int   arry_b [ALEN];
int * arry_c = (int*)0x10000000;

long unsigned int sum_arrys(
    int * aa,
    int * ab,
    int * ac,
    int   len
){
    long unsigned int sum = 0;

    for(int i = 0; i < len; i ++) {
        sum += aa[i];
        sum += ab[i];
        sum += ac[i];
    }

    return sum;
}

int main() {

    for(int i = 0; i < ALEN; i ++) {
        arry_a[i] = i;
        arry_b[i] = i;
    }

    for(int i = 0; i < ALEN; i ++) {
        arry_a[i] = arry_b[i] + arry_c[i];
    }

    long unsigned int sum = sum_arrys(arry_a,arry_b,arry_c,ALEN);

    if(sum > 0) {
        return SELFCHECK_PASS;
    } else {
        return SELFCHECK_FAIL;
    }

}
