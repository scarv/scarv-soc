

#include "selfcheck.h"

char * message = "Hello World!\n"
                 "This is the SCARV-CPU Talking.\n"
                 "The simulated UART Works :)\n";

int main() {

    for(int i = 0; i < 20; i++) {
        char to_echo = selfcheck_uart_getc();
        selfcheck_uart_putc(to_echo);
    }
        
    selfcheck_uart_putc('\n');
    
    for(int i = 0; message[i] != 0; i ++) {
        selfcheck_uart_putc(message[i]);
    }

    return SELFCHECK_PASS;   

}
