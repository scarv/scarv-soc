
#include "selfcheck.h"

int main() {

          int a     = 0;
          int b     = 1;
    const int max   = 1 << 24;

    while(b < max) {
        int tmp = b;
        tmp = b;
        b = a + b;
        a = tmp;
    }

    if(b > max) {
        return SELFCHECK_PASS;   
    } else {
        return SELFCHECK_FAIL;   
    }

}
