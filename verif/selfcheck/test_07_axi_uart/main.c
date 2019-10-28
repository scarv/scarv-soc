

#include "selfcheck.h"

char * message = "Hello World!\n"
                 "This is the SCARV-CPU Talking.\n"
                 "The simulated UART Works :)\n";

int main() {

    selfcheck_uart_getc();
    
    for(int i = 0; message[i] != 0; i ++) {
        selfcheck_uart_putc(message[i]);
    }

    return SELFCHECK_PASS;   

}
