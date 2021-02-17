
.extern fsbl
.extern panic_handler

.text
.global __fsbl_start
__fsbl_start:

    li x1 , 0
    la sp, __ccx_stack_start
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

    la      ra, __fsbl_panic
    csrw    mtvec, ra

    jal     fsbl                    // Jump to the first stage boot loader.

.global __fsbl_goto_main
__fsbl_goto_main:
    jalr    a0                      // Jump to pointer value passed in a0.

.balign 4
__fsbl_panic:
    csrr a0, mepc                   // Save useful variables.
    csrr a1, mstatus
    csrr a2, mtval  
    csrr a3, mcause 
    mv   a4, sp     
    mv   a5, ra     
    lhu  a6, 0(a0)                  // Load instruction at mepc
    lhu  a7, 2(a0)
    slli a7, a7, 16
    or   a6, a6, a7
    jal  panic_handler              // Goto the panic handler
    j    __fsbl_start               // Soft restart.

