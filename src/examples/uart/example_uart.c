
#include "scarvsoc.h"

char * finish_message = "\nRecieved Finish Byte. Stop.\n";

/*!
@brief A simple test program which echoes recieved UART bytes.
*/
int main(int argc, char ** argv) {
    
    char recv = scarvsoc_uart_getc_b(SCARVSOC_UART0);

    while(recv != '!') {

        scarvsoc_uart_putc_b(SCARVSOC_UART0, recv);

        recv = scarvsoc_uart_getc_b(SCARVSOC_UART0);

    }

    scarvsoc_uart_putstr_b(SCARVSOC_UART0, finish_message);

    return 0;
}
