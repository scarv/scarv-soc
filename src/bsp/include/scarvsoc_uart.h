
#include <stdint.h>

#ifndef SCARVSOC_UART_H
#define SCARVSOC_UART_H

/*!
@defgroup driver_uart UART
@brief API for the UART peripheral on the SCARV SoC
*/

//! Config object for a single instance of the SCARV SoC UART peripheral.
typedef volatile uint32_t * scarvsoc_uart_conf;


/*!
@brief Base address of the SCARVSOC UART peripheral
@ingroup driver_uart
*/
extern scarvsoc_uart_conf SCARVSOC_UART0;


/*!
@brief Write a single character to the simulated UART AXI device.
@note Does not block
@ingroup driver_uart
*/
void scarvsoc_uart_putc_nb(
    scarvsoc_uart_conf conf,    //!< The UART to access.
    char               tx       //!< Character to send.
);


/*!
@brief Write a single character to the simulated UART AXI device.
@note Blocks until the character is safely written to the device.
@ingroup driver_uart
*/
void scarvsoc_uart_putc_b(
    scarvsoc_uart_conf conf,    //!< The UART to access.
    char               tx       //!< Character to send.
);


/*!
@brief Read a single character to the simulated UART AXI device.
@note Blocks until a character is recieved.
@ingroup driver_uart
*/
char scarvsoc_uart_getc_b(
    scarvsoc_uart_conf conf     //!< The UART to access.
);


/*!
@brief Check if there are any UART bytes available?
@returns 
- Zero     if there are no bytes available.
- Non-zero if there are    bytes available.
@ingroup driver_uart
*/
char scarvsoc_uart_rx_avail(
    scarvsoc_uart_conf conf     //!< The UART to access.
);


/*!
@brief Check if there is space in the TX buffer for sending.
@returns 
- Zero     if there are is no space available.
- Non-zero if there are is    space available.
@ingroup driver_uart
*/
char scarvsoc_uart_tx_ready(
    scarvsoc_uart_conf conf     //!< The UART to access.
);


/*!
@brief Send a string of characters out via the UART
@note Blocks until all characters are sent. Uses scarvsoc_uart_putc_b
    underneath.
*/
void scarvsoc_uart_putstr_b (
    scarvsoc_uart_conf conf,    //!< The UART device to access
    char *             str      //!< The NULL terminated string to send.
);

#endif

