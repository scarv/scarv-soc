
#ifndef SELFCHECK_H
#define SELFCHECK_H

//! Pass code returned to the selfcheck tests bootloader.
#define SELFCHECK_PASS 0 

//! Failure code returned to the selfcheck tests bootloader.
#define SELFCHECK_FAIL 1

/*!
@brief Write a single character to the simulated UART AXI device.
@note Does not block
*/
void selfcheck_uart_putc(char tx);

/*!
@brief Read a single character to the simulated UART AXI device.
@note Blocks until a character is recieved.
*/
char selfcheck_uart_getc();

#endif

