
#include <stdint.h>


//! Jump to the main function
extern void __fsbl_goto_main(uint32_t * tgt);


/*!
@brief First stage boot loader function.
*/
void fsbl() {
    
    // 32-bit destination address.
    uint32_t    program_dest = 0x20000000;

    // Jump to the downloaded program.
    __fsbl_goto_main((uint32_t*)program_dest);

}
