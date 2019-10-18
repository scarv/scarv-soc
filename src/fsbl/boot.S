
.text
.global _start
_start:

    li x1 , 1
    li x2 , 1
    li x3 , 1
    li x4 , 1
    li x5 , 1
    li x6 , 1
    li x7 , 1
    li x8 , 1
    li x9 , 1
    li x10, 1
    li x11, 1
    li x12, 1
    li x13, 1
    li x14, 1
    li x15, 1
    li x16, 1
    li x17, 1
    li x18, 1
    li x19, 1
    li x20, 1
    li x21, 1
    li x22, 1
    li x23, 1
    li x24, 1
    li x25, 1
    li x26, 1
    li x27, 1
    li x28, 1
    li x29, 1
    li x30, 1
    li x31, 1

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

