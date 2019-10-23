
#include "selfcheck.h"

#define ALEN 20

extern int test_data_error(
    char * addr,
    char   expect_error
);

int main() {

    int result;
  
    result = test_data_error((char*)0x90000000, 1)  ;

    if(result) {
        return SELFCHECK_FAIL;
    }
    

    return SELFCHECK_PASS;
}
