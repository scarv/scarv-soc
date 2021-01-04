
#include <stdint.h>

#ifndef UART_BASE
    #define UART_BASE 0x10000000
#endif

#ifndef GPIO_BASE
    #define GPIO_BASE 0x10001000
#endif

#define UART_RX 0
#define UART_TX 1
#define UART_ST 2
#define UART_CT 3

#define GPIO_DIR 2
#define GPIO_OUT 1

//! Pointer to the UART and GPIO register space.
static volatile uint32_t * uart = (volatile uint32_t*)(UART_BASE);
static volatile uint32_t * gpio = (volatile uint32_t*)(GPIO_BASE);

static volatile uint32_t * ram  = (volatile uint32_t*)(0x00010000);

static const uint32_t UART_CTRL_RST_TX_FIFO = 0x1 << 5;
static const uint32_t UART_CTRL_RST_RX_FIFO = 0x1 << 6;

static const uint32_t UART_STATUS_TX_BUSY   = 0x1 << 5;
static const uint32_t UART_STATUS_TX_FULL   = 0x1 << 4;
static const uint32_t UART_STATUS_RX_VALID  = 0x1 << 0;

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

static const char lut []= "0123456789ABCDEF";

//! Print a 32-bit number as hex
void puthex32(uint32_t w) {
    char b[3];
    b[2]= 0;
    for(int i =  3; i >= 0; i --) {
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
    uint32_t    program_size = 0;
    program_size |= ((uint32_t)uart_rd_char() << 24) ;
    program_size |= ((uint32_t)uart_rd_char() << 16) ;
    program_size |= ((uint32_t)uart_rd_char() <<  8) ;
    program_size |= ((uint32_t)uart_rd_char() <<  0) ;

    // Next 4 bytes are a 32-bit destination address.
    uint32_t    program_dest = 0;
    program_dest |= ((uint32_t)uart_rd_char() << 24) ;
    program_dest |= ((uint32_t)uart_rd_char() << 16) ;
    program_dest |= ((uint32_t)uart_rd_char() <<  8) ;
    program_dest |= ((uint32_t)uart_rd_char() <<  0) ;

    uint8_t * dest_ptr = (uint8_t*)program_dest;

    // Download the program and write it to the destination memory.
    for(int32_t i = 0; i < program_size; i ++) {
        dest_ptr[i] = uart_rd_char();
    }
        
    puthex32(program_size);
    putstr(", ");
    puthex32(program_dest);
    putstr("\n");

    for(int i = 0; i < 1+program_size/4; i ++) {
        puthex32((uint32_t)dest_ptr);
        putstr(" ");
        puthex32(((uint32_t*)dest_ptr)[i]);
        putstr("\n");
    }
    
    putstr("boot\n");
        
    while(uart[UART_ST] & UART_STATUS_TX_FULL) {
        // Do nothing. Wait for all UART traffic to finish.
    }   

    // Jump to the downloaded program.
    __fsbl_goto_main((uint32_t*)program_dest);

}

/*!
@brief FSBL panic handler.
@details Prints register state, then jumps back to __fsbl_start
*/
void panic_handler(
    uint32_t mepc   ,
    uint32_t mstatus,
    uint32_t mtval  ,
    uint32_t mcause ,
    uint32_t sp     ,
    uint32_t ra     ,
    uint32_t instr
){
    
    
    putstr("\npanic!\n");
    
    putstr("mepc: "     ); puthex32(mepc   ); putstr("\n");    
    putstr("inst: "     ); puthex32(instr  ); putstr("\n");    
    putstr("mstatus: "  ); puthex32(mstatus); putstr("\n");    
    putstr("mtval: "    ); puthex32(mtval  ); putstr("\n");    
    putstr("mcause: "   ); puthex32(mcause ); putstr("\n");    
    putstr("sp: "       ); puthex32(sp     ); putstr("\n");    
    putstr("ra: "       ); puthex32(ra     ); putstr("\n");    
    putstr("\n--------\n");

    // Wait for all UART data to be dumped out.
    while(uart[UART_ST] & UART_STATUS_TX_BUSY) {}

    while(1){} // Hang forever until reset.

    return;
}
