

.global axi_access_test
.func axi_access_test
axi_access_test:

    li a0, 1

    li t0, 0x40000000           // t0 = base address of the AXI region.

    lw zero, 0(t0)              // try loading something from the AXI region.

    addi t1, t0, 100

    //
    // Loads

    .loop_1:

        lb zero, 0(t0)          // try loading something from the AXI region.

        addi t0, t0, 1

        bltu t0, t1, .loop_1
    
    li t0, 0x40000000           // t0 = base address of the AXI region.
    addi t1, t0, 100
    
    .loop_2:

        lb zero, 0(t0)          // try loading something from the AXI region.
        lb zero, 1(t0)          //

        addi t0, t0, 2

        bltu t0, t1, .loop_2
    
    li t0, 0x40000000           // t0 = base address of the AXI region.
    addi t1, t0, 100
    
    .loop_3:

        lh zero, 0(t0)          // try loading something from the AXI region.
        lh zero, 2(t0)          //
        lh zero, 4(t0)          //

        addi t0, t0,62

        bltu t0, t1, .loop_3

    //
    // Stores

    .loop_4:

        sb zero, 0(t0)          // try loading something from the AXI region.

        addi t0, t0, 1

        bltu t0, t1, .loop_4
    
    li t0, 0x40000000           // t0 = base address of the AXI region.
    addi t1, t0, 100
    
    .loop_5:

        sb zero, 0(t0)          // try loading something from the AXI region.
        sb zero, 1(t0)          //

        addi t0, t0, 2

        bltu t0, t1, .loop_5
    
    li t0, 0x40000000           // t0 = base address of the AXI region.
    addi t1, t0, 100
    
    .loop_6:

        sh zero, 0(t0)          // try loading something from the AXI region.
        sh zero, 2(t0)          //
        sh zero, 4(t0)          //

        addi t0, t0,62

        bltu t0, t1, .loop_6
    
    li t0, 0x40000000           // t0 = base address of the AXI region.
    addi t1, t0, 100

    lw  zero, 0(t0)
    sw  zero, 4(t0)
    lw  zero, 8(t0)
    sw  zero, 0(t0)
    lw  zero, 4(t0)
    sw  zero, 8(t0)
    lw  zero, 0(t0)

    li a0, 0

    ret
.endfunc
