
MEMORY {
    ram (rxwa)  : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS {

    . = 0x20000000;

    .text : SUBALIGN(4) { 
        *(.text.*)
        *(.text)
        . = ALIGN(4);
    } > ram
    .data : {
        *(.data.*)
        *(.rodata.*)
        . = ALIGN(4);
    } > ram
    .bss  : {
        *(.bss)
        . = ALIGN(4);
    } > ram

    /DISCARD/ : { *(.comment) }

}

