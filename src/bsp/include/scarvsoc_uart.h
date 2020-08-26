
#include <stdint.h>
#include <stdlib.h>

#ifndef SCARVSOC_UART_H
#define SCARVSOC_UART_H

/*!
@defgroup driver_uart UART
@brief API for the UART peripheral on the SCARV SoC
@details The UART can be used by including "scarvsoc_uart.h".
*/

/*!
@ingroup driver_uart
@file scarvsoc_uart.h
*/

//! Config object for a single instance of the SCARV SoC UART peripheral.
typedef volatile uint32_t * scarvsoc_uart_conf;


/*!
@brief Base address of the SCARVSOC UART peripheral
@ingroup driver_uart
*/
extern scarvsoc_uart_conf SCARVSOC_UART0;

//! Status reg bit: Did we cause an interrupt?
extern const uint32_t SCARVSOC_UART_STAT_INT     ;

//! Status reg bit: Are we currently sending any data?
extern const uint32_t SCARVSOC_UART_STAT_TX_BUSY ;

//! Status reg bit: Is the transmit data FIFO full?
extern const uint32_t SCARVSOC_UART_STAT_TX_FULL ;

//! Status reg bit: Have we recieved a break message?
extern const uint32_t SCARVSOC_UART_STAT_RX_BREAK;

//! Status reg bit: Are we currently recieving anything?
extern const uint32_t SCARVSOC_UART_STAT_RX_BUSY ;

//! Status reg bit: Is the RX FIFO full?
extern const uint32_t SCARVSOC_UART_STAT_RX_FULL ;

//! Status reg bit: Does the RX FIFO have valid data to recieve?
extern const uint32_t SCARVSOC_UART_STAT_RX_VALID;

//! Control reg bit: Clear the RX FIFO contents
extern const uint32_t SCARVSOC_UART_CTRL_CLEAR_RX       ;

//! Control reg bit: Clear the RX FIFO contents
extern const uint32_t SCARVSOC_UART_CTRL_CLEAR_TX       ;

//! Control reg bit: Clear the break indicator bit.
extern const uint32_t SCARVSOC_UART_CTRL_CLEAR_BREAK    ;

//! Control reg bit: Clear the interrupt indicator bit.
extern const uint32_t SCARVSOC_UART_CTRL_CLEAR_INT      ;

//! Control reg bit: Enable interrupt when break is recieved.
extern const uint32_t SCARVSOC_UART_CTRL_EN_INT_BREAK   ;

//! Control reg bit: Enable interrupt when any valid RX data is available.
extern const uint32_t SCARVSOC_UART_CTRL_EN_INT_RX_ANY  ;

//! Control reg bit: Enable interrupt when the RX FIFO is full.
extern const uint32_t SCARVSOC_UART_CTRL_EN_INT_RX_FULL ;

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
@ingroup driver_uart
*/
void scarvsoc_uart_putstr_b (
    scarvsoc_uart_conf conf,    //!< The UART device to access
    char *             str      //!< The NULL terminated string to send.
);

/*!
@brief Read a string of given length from the UART.
@note Blocks until all characters are recieved.
@ingroup driver_uart
*/
void scarvsoc_uart_getstr_b (
    scarvsoc_uart_conf conf,    //!< The UART device to access
    char *             str,     //!< Buffer to store the recieved string in.
    size_t             len      //!< Number of characters to recieve.
);

#endif

