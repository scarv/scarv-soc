
#include <stdint.h>

#ifndef UART_BASE
    #define UART_BASE 0x10000000
#endif

#define UART_RX 0
#define UART_TX 1
#define UART_ST 2
#define UART_CT 3

//! Pointer to the UART register space.
static volatile uint32_t * uart = (volatile uint32_t*)(UART_BASE);

const uint32_t UART_CTRL_RST_TX_FIFO = 0x1 << 5;
const uint32_t UART_CTRL_RST_RX_FIFO = 0x1 << 6;

const uint32_t UART_STATUS_RX_VALID  = 0x1 << 0;
const uint32_t UART_STATUS_TX_FULL   = 0x1 << 4;

//! Read a single character from the UART.
uint8_t uart_rd_char(){
    while(!(uart[UART_ST] & UART_STATUS_RX_VALID)) {
        // Do nothing.
    }
    return (uint8_t)uart[UART_RX];
}

//! Jump to the main function
extern void __fsbl_goto_main(uint32_t * tgt);

//! The very first thing executed.
extern void __fsbl_start();

/*!
@brief Setup the UART peripheral
@details Configures the UART peripheral such that:
- The TX and RX fifos are empty
- Interrupts are disabled
*/
void fsbl_uart_setup() {
    uart[UART_CT] = UART_CTRL_RST_TX_FIFO | UART_CTRL_RST_RX_FIFO ;
}

/*!
@brief Print the simple welcome message to show we are ready.
*/
void putstr(char * msg) {
    for(int i = 0; msg[i]; i ++) {
        while(uart[UART_ST] & UART_STATUS_TX_FULL) {
            // Do nothing.
        }   
        uart[UART_TX] = msg[i];
    }
}


//! Print a 32-bit number as hex
void puthex32(uint32_t w) {
    char lut []= "0123456789ABCDEF";
    for(int i =  3; i >= 0; i --) {
        char b[3];
        b[1]= lut[(w >> (8*i    )) & 0xF];
        b[0]= lut[(w >> (8*i + 4)) & 0xF];
        putstr(b);
    }
}


/*!
@brief
    First stage boot loader function.

@details 
    Works to download a program over the UART into the RAM
    memory segment, then jumps to the RAM.
*/
void fsbl() {

    fsbl_uart_setup();

    putstr("scarv-soc fsbl\n");
    
    // First 4 bytes are the size of the program (in bytes).
    uint32_t    program_size =
        ((uint32_t)uart_rd_char() << 24) |
        ((uint32_t)uart_rd_char() << 16) |
        ((uint32_t)uart_rd_char() <<  8) |
        ((uint32_t)uart_rd_char() <<  0) ;

    // Next 4 bytes are a 32-bit destination address.
    uint32_t    program_dest =
        ((uint32_t)uart_rd_char() << 24) |
        ((uint32_t)uart_rd_char() << 16) |
        ((uint32_t)uart_rd_char() <<  8) |
        ((uint32_t)uart_rd_char() <<  0) ;

    uint8_t * dest_ptr = (uint8_t*)program_dest;

    // Download the program and write it to the destination memory.
    for(uint32_t i = 0; i < program_size; i ++) {
        dest_ptr[i] = uart_rd_char();
    }
    
    putstr("boot\n");

    // Jump to the downloaded program.
    __fsbl_goto_main((uint32_t*)program_dest);

}

/*!
@brief FSBL panic handler.
@details Prints register state, then jumps back to __fsbl_start
*/
void panic() {
    putstr("\npanic!\n");
    uint32_t mepc, mstatus, mtval, mcause, sp, ra;
    
    asm volatile("csrr %0, mepc     " : "=r"(mepc   ));
    puthex32(mepc   );putstr("\n");    
    
    asm volatile("csrr %0, mstatus  " : "=r"(mstatus));
    puthex32(mstatus);putstr("\n");    
    
    asm volatile("csrr %0, mtval    " : "=r"(mtval  ));
    puthex32(mtval  );putstr("\n");    
    
    asm volatile("csrr %0, mcause   " : "=r"(mcause ));
    puthex32(mcause );putstr("\n");    
    
    asm volatile("mv   %0, sp       " : "=r"(sp     ));
    puthex32(sp     );putstr("\n");    
    
    asm volatile("mv   %0, ra       " : "=r"(ra     ));
    puthex32(ra     );putstr("\n");    

    __fsbl_start();   
}
