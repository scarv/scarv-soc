
MEMORY {
    rom (rx)    : ORIGIN = 0x10000000, LENGTH = 1K
}

SECTIONS {

    . = 0x10000000;

    .text ALIGN(4) : SUBALIGN(4) {
        *(.text.*) 
        *(.text) 
        . = ALIGN(4);
    } > rom
    .data ALIGN(4) : SUBALIGN(4) { *(.data.*) } > rom
    .bss  ALIGN(4) : SUBALIGN(4) { *(.bss)    } > rom

    /DISCARD/ : { *(.comment) }

}
