
#include "stddef.h"

#include "selfcheck.h"

#define ALEN 20

/*!
@brief Checks if a specified address correctly triggers 
a data load trap or not
*/
extern int test_data_load_error(
    char * addr,
    char   expect_error
);

typedef struct {
    char * addr;
    char   expect_error;
} test_spec_t;

test_spec_t tests [] = {
    {.addr = (char*)0x90000000, .expect_error = 1},
    {.addr = (char*)0xA0000000, .expect_error = 1},
    {.addr = (char*)0x50000000, .expect_error = 1},
    {.addr = (char*)0x3FFFFFFF, .expect_error = 1},
    {.addr = (char*)0x20010000, .expect_error = 1},
    {.addr = (char*)0x1FFFFFFF, .expect_error = 1},
    {.addr = (char*)0x10000400, .expect_error = 1},
    {.addr = (char*)0x0FFFFFFF, .expect_error = 1} 
};

int main() {

    int result;
  
    size_t num_tests = sizeof(tests) / sizeof(test_spec_t);

    for(int i = 0; i < num_tests; i ++) {

        result = test_data_load_error(
            tests[i].addr,
            tests[i].expect_error
        );

        if(result) {
            return SELFCHECK_FAIL;
        }

    }
    

    return SELFCHECK_PASS;
}
