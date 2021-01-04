
#include "scarvsoc.h"

//char * finish_message = "\nRecieved Finish Byte. Stop.\n";

#ifndef UART_BASE
    #define UART_BASE 0x10000000
#endif

#define UART_RX 0
#define UART_TX 1
#define UART_ST 2
#define UART_CT 3

//! Pointer to the UART register space.
static volatile uint32_t * uart = (volatile uint32_t*)(UART_BASE);

static const uint32_t UART_STATUS_TX_BUSY   = 0x1 << 5;
static const uint32_t UART_STATUS_TX_FULL   = 0x1 << 4;

void putstr(char * msg) {
    for(int i = 0; msg[i]; i ++) {
        while(uart[UART_ST] & UART_STATUS_TX_FULL) {
            // Do nothing.
        }   
        uart[UART_TX] = msg[i];
    }
}

/*!
@brief A simple test program which echoes recieved UART bytes.
*/
int main(int argc, char ** argv) {

    putstr("Hello, World!\n");

    return 0;
}
