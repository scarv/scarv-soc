
#include "scarvsoc_uart.h"

/*!
@ingroup driver_uart
@file scarvsoc_uart.c
@note This file implements the UART driver expecting the Xilinx UARTLite
peripheral, as described in the link below:
https://www.xilinx.com/support/documentation/ip_documentation/axi_uartlite/v2_0/pg142-axi-uartlite.pdf
*/

scarvsoc_uart_conf  SCARVSOC_UART0= (scarvsoc_uart_conf)0x10000000;

//! Recieve data FIFO register index.
static const uint32_t scarvsoc_uart_reg_rx  = 0x0;

//! Transmit data FIFO register index.
static const uint32_t scarvsoc_uart_reg_tx  = 0x1;

//! Status register index.
static const uint32_t scarvsoc_uart_reg_stat= 0x2;

// Control register index.
//static const uint32_t scarvsoc_uart_reg_ctrl= 0x3;


/*!
@warning This function does not block waiting for the UART TX queue,
    so might drop characters if you don't periodically drain the TX queue.
*/
void scarvsoc_uart_putc_nb(
    scarvsoc_uart_conf conf,
    char               tx
){
    conf[scarvsoc_uart_reg_tx] = (uint32_t)tx;
}


/*!
*/
void scarvsoc_uart_putc_b(
    scarvsoc_uart_conf conf,
    char               tx
){
    while(!scarvsoc_uart_tx_ready(conf)) {
        // Do nothing / wait.
    }
    conf[scarvsoc_uart_reg_tx] = (uint32_t)tx;
}


/*!
*/
char scarvsoc_uart_getc_b(
    scarvsoc_uart_conf conf
){
    while(!scarvsoc_uart_rx_avail(conf)) {
        // Do nothing / wait.
    }
    return (char)conf[scarvsoc_uart_reg_rx];
}


/*!
*/
char scarvsoc_uart_rx_avail(
    scarvsoc_uart_conf conf
){
    return (conf[scarvsoc_uart_reg_stat] & 0x01);
}


/*!
*/
char scarvsoc_uart_tx_ready(
    scarvsoc_uart_conf conf
){
    return !(conf[scarvsoc_uart_reg_stat] & (0x01 << 3));
}


/*!
*/
void scarvsoc_uart_putstr_b (
    scarvsoc_uart_conf conf,
    char *             str  
){
    while(*str != '\0') {
        
        scarvsoc_uart_putc_b(conf, *str);

        str++;

    }
}

/*!
@warning This function will block forever until the right number of
    bytes has been recieved.
*/
void scarvsoc_uart_getstr_b (
    scarvsoc_uart_conf conf,
    char *             str, 
    size_t             len  
){

    for(size_t i = 0; i < len; i ++) {
        str[i] = scarvsoc_uart_getc_b(conf);
    }

}

