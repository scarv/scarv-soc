
.global test_data_load_error
.func   test_data_load_error
test_data_load_error:
    // a0 = address to test.
    // a1 = error expected?

    la      t0, test_data_error_handler
    csrrw   t0, mtvec, t0           // Save normal trap vector and set new

    li      t1, 0xA                 // Set t1 value to indicate no trap.
    
    epc_expected:                   // Label we expect EPC to be.
        lbu     zero, 0(a0)         // Load and cause a bus error

    li      t2, 0xB
    beq     t2, t1,    match
    j               no_match

    match:                          // No trap occured
        beqz a1, test_pass          // - That was     expected
        j        test_fail          // - That was not expected

    no_match:                       // A trap occured
        beqz a1, test_fail          // - That was not expected
        j        test_pass          // - That was     expected

    test_fail:
        li a0, 1                    // return non-zero
        j  test_finish

    test_pass:
        li a0, 0                    // return zero
        j   test_finish
    
    test_finish:

    csrw    mtvec, t0               // Restore the normal trap vector.
    ret

.endfunc

//
// Handles the trap we generate.
//
.align 4
test_data_error_handler:

    csrr    t5, mcause              // Did we fail for the right reason?
    li      t6, 5                   // Cause = load access fault
    bne     t5, t6, handler_fail

    la      t6, epc_expected
    csrr    t5, mepc
    bne     t5, t6, handler_fail    // Did we fail at the right instruction?


    j   handler_pass

    handler_fail:
        li  t2, 0xA                 // Load failure code in t2
        j   handler_finish

    handler_pass:
        li  t2, 0xB                 // Load pass code in t2

    lbu     t4, 0(t5)               // Size of failing instruction?
    andi    t4, t4, 0b11
    li      t6, 0b11

    beq     t4, t6, handler_add_4   // Add 2 or 4 to EPC?
    
    handler_add_2:
        addi t5,t5,2
        j handler_add_done

    handler_add_4:
        addi t5,t5,4

    handler_add_done:               // Put back incremented EPC.
        csrw    mepc, t5
    
    handler_finish:
        mret
