
#include <stdint.h>

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

//! Seed the XCrypto RNG
static inline  void    _xc_rngseed (uint32_t seed) {             __asm__ volatile ("xc.rngseed  %0" :          : "r"(seed));           }

//! Sample the XCrypto RNG                                                       
static inline uint32_t _xc_rngsamp (             ) {uint32_t rd; __asm__ volatile ("xc.rngsamp  %0" : "=r"(rd) :          ); return rd;}

//! Check the XCrypto RNG is healthy                                             
static inline uint32_t _xc_rngtest (             ) {uint32_t rd; __asm__ volatile ("xc.rngtest  %0" : "=r"(rd) :          ); return rd;}

#endif

