
//
// selfcheck.S
//
// Shared assembly code used by the self checking tests.
//
//


.global selfcheck_uart_putc
.func   selfcheck_uart_putc
selfcheck_uart_putc:
    li  a1, 0x40001000
    sw  a0, 0(a1)
    ret
.endfunc
