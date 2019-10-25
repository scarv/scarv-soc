
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

.global selfcheck_uart_getc
.func   selfcheck_uart_getc
selfcheck_uart_getc:
    li  a1, 0x40001000

    .getc_loop:
        lw      a0, 12(a1)
        andi    a0, a0, 0x1
        beqz    a0, .getc_loop

    lw  a0, 4(a1)

    ret
.endfunc
