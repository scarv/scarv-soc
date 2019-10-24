
.global test_data_store_error
.func   test_data_store_error
test_data_store_error:
    // a0 = address to test.
    // a1 = error expected?

    addi    sp, sp, -4
    sw      ra, 0(sp)

    la      t0, test_data_error_handler
    csrrw   t0, mtvec, t0           // Save normal trap vector and set new

    li      t1, 0xA                 // Set t1 value to indicate no trap.
    
    // Trap occurs on target of this jump.
    // We use the ra register to get back to after this instruction from
    // the trap handler by writing it into the EPC before the mret.
    jalr  a0                        // Jump to target

    li      t2, 0xB
    beq     t2, t1,    match
    j               no_match

    match:                          // No trap occured
        beqz a1, test_fail          // - That was not expected
        j        test_pass          // - That was     expected

    no_match:                       // A trap occured
        beqz a1, test_pass          // - That was not expected
        j        test_fail          // - That was     expected

    test_fail:
        li a0, 1                    // return non-zero
        j  test_finish

    test_pass:
        li a0, 0                    // return zero
        j   test_finish
    
    test_finish:

    csrw    mtvec, t0               // Restore the normal trap vector.
    
    lw      ra, 0(sp)
    addi    sp, sp,  4

    ret

.endfunc

//
// Handles the trap we generate.
//
.align 4
test_data_error_handler:

    csrr    t5, mcause              // Did we fail for the right reason?
    li      t6, 1                   // Cause = Instruction access fault.
    bne     t5, t6, handler_fail

    j   handler_pass

    handler_fail:
        li  t1, 0xA                 // Load failure code in t2
        j   handler_finish

    handler_pass:
        li  t1, 0xB                 // Load pass code in t2

    handler_finish:
        csrw    mepc, ra
        mret
