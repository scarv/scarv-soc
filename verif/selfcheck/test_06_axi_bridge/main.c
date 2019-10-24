
#include "selfcheck.h"

// Declaration of test function in asm file.
extern int axi_access_test();

int main() {

    int result = axi_access_test();

    if(result){
        return SELFCHECK_FAIL;
    } else {
        return SELFCHECK_PASS;
    }

}
