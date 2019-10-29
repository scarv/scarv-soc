
MEMORY {
    rom (rx)    : ORIGIN = 0x10000000, LENGTH = 1K
}

SECTIONS {

    . = 0x10000000;

    .text : SUBALIGN(4) { *(.text.*) } > rom
    .data :             { *(.data.*) } > rom
    .bss  :             { *(.bss)    } > rom

    /DISCARD/ : { *(.comment) }

}
