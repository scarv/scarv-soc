
.text
.global _start
_start:
    j       _bl_main

_bl_test_pass:
	j       _bl_test_pass

_bl_test_fail:
	j       _bl_test_fail


_bl_main:

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
    
    
    csrw    mstatus, zero       // Disable interrupts

    la      s0, _bl_excep_handler
    csrw    mtvec, s0

    li      sp, 0x2000FFF0      // Initialise stack pointer.

    li      s0, 0x20000000      // Load Main function target address
    jalr    s0                  // Call the test main function.

    beqz    a0, _bl_test_pass   // If we passed, goto pass address.
    j       _bl_test_fail       // If we failed, goto the fail address.

.align 2
_bl_excep_handler:
    j       _bl_test_fail       // Fail immediately on any unplanned trap.
