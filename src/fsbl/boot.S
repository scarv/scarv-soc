
.text
.global _start
_start:

    li x1 , 0
    li x2 , 0
    li x3 , 0
    li x4 , 0
    li x5 , 0
    li x6 , 0
    li x7 , 0
    li x8 , 0
    li x9 , 0
    li x10, 0
    li x11, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0
    li x16, 0
    li x17, 0
    li x18, 0
    li x19, 0
    li x20, 0
    li x21, 0
    li x22, 0
    li x23, 0
    li x24, 0
    li x25, 0
    li x26, 0
    li x27, 0
    li x28, 0
    li x29, 0
    li x30, 0
    li x31, 0

    li sp, 0x2000FFFF

    li t0, 0x10000000
    li t1, 0x10000400
    li t2, 0x20000000

    cpy_loop:
        lw   a0, 0(t0)
        lw   a1, 4(t0)
        lw   a2, 8(t0)
        lw   a3,12(t0)
        addi t0, t0, 16

        sw   a0, 0(t2)
        sw   a1, 4(t2)
        sw   a2, 8(t2)
        sw   a3,12(t2)
        addi t2, t2, 16

        bltu t0, t1, cpy_loop


    j       fsbl                    // Jump to the first stage boot loader.

.global __fsbl_goto_main
__fsbl_goto_main:
    jalr    zero, a0                // Jump to pointer value passed in a0.

