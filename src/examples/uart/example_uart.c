
#include "scarvsoc.h"

//char * finish_message = "\nRecieved Finish Byte. Stop.\n";

#ifndef UART_BASE
    #define UART_BASE 0x10000000
#endif

#ifndef GPIO_BASE
    #define GPIO_BASE 0x10001000
#endif

#define GPIO_DIR 1
#define GPIO_OUT 0

#define UART_RX 0
#define UART_TX 1
#define UART_ST 2
#define UART_CT 3

//! Pointer to the UART register space.
static volatile uint32_t * uart = (volatile uint32_t*)(UART_BASE);

static const uint32_t UART_CTRL_RST_TX_FIFO = 0x1 << 5;
static const uint32_t UART_CTRL_RST_RX_FIFO = 0x1 << 6;

static const uint32_t UART_STATUS_TX_FULL   = 0x1 << 3;
static const uint32_t UART_STATUS_RX_VALID  = 0x1 << 0;

//! Read a single character from the UART.
uint8_t uart_rd_char(){
    while(!(uart[UART_ST] & UART_STATUS_RX_VALID)) {
        // Do nothing.
    }
    return (uint8_t)uart[UART_RX];
}
    
void uart_wr_char(uint8_t c) {
    while(uart[UART_ST] & UART_STATUS_TX_FULL) {
        // Do nothing.
    }   
    uart[UART_TX] = c;
}

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

    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO0,0x00);
    scarvsoc_uart_putstr_b(SCARVSOC_UART0,"Hello, World!\n");
    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO0,0x0F);

    char c = 0;
    while(c != '!') {
        c = scarvsoc_uart_getc_b(SCARVSOC_UART0);
        scarvsoc_uart_putc_b(SCARVSOC_UART0,c);
        scarvsoc_gpio_set_outputs(SCARVSOC_GPIO0,c);
        scarvsoc_gpio_set_outputs(SCARVSOC_GPIO1,c);
    }

    return 0;
}
