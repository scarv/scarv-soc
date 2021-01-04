
#include "scarvsoc_uart.h"

/*!
@ingroup driver_uart
@file scarvsoc_uart.c
*/

scarvsoc_uart_conf  SCARVSOC_UART0= (scarvsoc_uart_conf)0x10000000;

#define UART_RX 0
#define UART_TX 1
#define UART_ST 2
#define UART_CT 3

#define SCARVSOC_UART_STAT_INT               (0x1 << 6)
#define SCARVSOC_UART_STAT_TX_BUSY           (0x1 << 5)
#define SCARVSOC_UART_STAT_TX_FULL           (0x1 << 4)
#define SCARVSOC_UART_STAT_RX_BREAK          (0x1 << 3)
#define SCARVSOC_UART_STAT_RX_BUSY           (0x1 << 2)
#define SCARVSOC_UART_STAT_RX_FULL           (0x1 << 1)
#define SCARVSOC_UART_STAT_RX_VALID          (0x1 << 0)

#define SCARVSOC_UART_CTRL_CLEAR_RX          (0x1 << 6)
#define SCARVSOC_UART_CTRL_CLEAR_TX          (0x1 << 5)
#define SCARVSOC_UART_CTRL_CLEAR_BREAK       (0x1 << 4)
#define SCARVSOC_UART_CTRL_CLEAR_INT         (0x1 << 3)
#define SCARVSOC_UART_CTRL_EN_INT_BREAK      (0x1 << 2)
#define SCARVSOC_UART_CTRL_EN_INT_RX_ANY     (0x1 << 1)
#define SCARVSOC_UART_CTRL_EN_INT_RX_FULL    (0x1 << 0)


/*!
@warning This function does not block waiting for the UART TX queue,
    so might drop characters if you don't periodically drain the TX queue.
*/
void scarvsoc_uart_putc_nb(
    scarvsoc_uart_conf conf,
    char               tx
){
    conf[UART_TX] = (uint32_t)tx;
}


/*!
*/
void scarvsoc_uart_putc_b(
    scarvsoc_uart_conf conf,
    char               tx
){
    while(conf[UART_ST] & SCARVSOC_UART_STAT_TX_FULL) {
        // Do nothing / wait.
    }
    conf[UART_TX] = (uint32_t)tx;
}


/*!
*/
char scarvsoc_uart_getc_b(
    scarvsoc_uart_conf conf
){
    while(!scarvsoc_uart_rx_avail(conf)) {
        // Do nothing / wait.
    }
    return (char)conf[UART_RX];
}


/*!
*/
char scarvsoc_uart_rx_avail(
    scarvsoc_uart_conf conf
){
    return (conf[UART_ST] & SCARVSOC_UART_STAT_RX_VALID);
}


/*!
*/
char scarvsoc_uart_tx_ready(
    scarvsoc_uart_conf conf
){
    return !(conf[UART_ST] & SCARVSOC_UART_STAT_TX_FULL);
}


/*!
*/
void scarvsoc_uart_putstr_b (
    scarvsoc_uart_conf conf,
    char *             str  
){
    for(int i=0; str[i]; i ++) {
        
        while(conf[UART_ST] & SCARVSOC_UART_STAT_TX_FULL) {
            // Do nothing.
        }   
        conf[UART_TX] = str[i];

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

