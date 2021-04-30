
.macro mask RD RS1
    .insn r CUSTOM_0, 1    , 0    , \RD, \RS1 ,x0 ;
.endm

.macro remask RD RS1
    .insn r CUSTOM_0, 2    , 0    , \RD, \RS1 ,x0 ;
.endm

.macro unmask RD RS1
    .insn r CUSTOM_0, 4    , 0    , \RD, \RS1 ,x0 ;
.endm

.text
.global experiment_payload
.func   experiment_payload
experiment_payload:

    mv      x16, a0             // Move input variables to SME registers.
    mv      x17, a1
    li      a0 , 0              // Destroy the input variables.
    li      a1 , 0
    li t0, 0x1E0                // D=max, bank=0
    csrrw x0, 0x006, t0         // Turn on SME with MAX shares and 0'th bank.
    mask    x16, x16            // En-mask the input variables.
    mask    x17, x16
    li      x18, 0

.rept 15
    xor     x0, x0, x0
.endr

    aes32esi x16, x17, 0
    aes32esi x16, x17, 1
    aes32esi x16, x17, 2
    aes32esi x16, x17, 3
    
.rept 15
    xor     x0, x0, x0
.endr

    unmask  a0, x16             // Unmask the result.
    csrrw x0, 0x006, x0         // Turn off SME

    ret
.endfunc
