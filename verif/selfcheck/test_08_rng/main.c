
#include "selfcheck.h"

#define NSAMPLES 10
#define NLOOPS   10

/*!
@details
This is a very simple test which just makes sure we can use the
XCrypto random number interface without hanging the core.
It does not check that the RNG is functioning correctly!
*/
int main() {

    uint32_t numbers [NSAMPLES] ;

    uint32_t sum    = 0         ;

    // Back to back reading. Not recommended, but someone will do it.
    numbers[0] = _xc_rngsamp();
    numbers[1] = _xc_rngsamp();
    numbers[2] = _xc_rngsamp();
    numbers[3] = _xc_rngsamp();
    numbers[4] = _xc_rngsamp();
    numbers[5] = _xc_rngsamp();
    numbers[6] = _xc_rngsamp();

    sum = numbers[0] ^ numbers[1] ^ numbers[2];

    // Back to back status checking
    _xc_rngtest();
    _xc_rngtest();
    _xc_rngtest();
    _xc_rngtest();
    _xc_rngtest();
    
    // Back to back seeding
    _xc_rngseed(sum);
    _xc_rngseed(sum);
    _xc_rngseed(sum);
    _xc_rngseed(sum);
    _xc_rngseed(sum);
    _xc_rngseed(sum);
    _xc_rngseed(sum);

    // Read in a loop
    for (int l = 0; l < NLOOPS; l ++) {

        for(int i  = 0 ; i < NSAMPLES; i++) {

            if(_xc_rngtest()) {
                numbers[i] = _xc_rngsamp();

                sum       ^= numbers[i];
            }

        }

        _xc_rngseed(sum);

    }

    return 0;

}
