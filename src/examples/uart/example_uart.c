
#include "scarvsoc.h"

char * start_message  = "UART Echo Example Program\n"    ;
char * finish_message = "\nRecieved Finish Byte. Stop.\n";

/*!
@brief A simple test program which echoes recieved UART bytes.
*/
int main(int argc, char ** argv) {

    scarvsoc_uart_getc_b(SCARVSOC_UART0);
    
    scarvsoc_uart_putstr_b(SCARVSOC_UART0, start_message);
    
    char recv = scarvsoc_uart_getc_b(SCARVSOC_UART0);

    uint32_t counter = 0;

    while(recv != '!') {

        scarvsoc_uart_putc_b(SCARVSOC_UART0, recv);

        recv = scarvsoc_uart_getc_b(SCARVSOC_UART0);

        counter ++;

        scarvsoc_gpio_wr(SCARVSOC_GPIO1, counter);

    }

    scarvsoc_uart_putstr_b(SCARVSOC_UART0, finish_message);
    
    scarvsoc_gpio_wr(SCARVSOC_GPIO1, 0);

    return 0;
}
