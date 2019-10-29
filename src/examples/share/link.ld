
MEMORY {
    rom (rx)    : ORIGIN = 0x10000000, LENGTH = 1K
    ram (rxwa)  : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS {

    . = 0x20000000;

    .text ALIGN(4) : SUBALIGN(4) { *(.text.*) } > ram
    .data : { 
        *(.data.*) 
        _edata = .;
        PROVIDE(_edata = .);
    } > ram
    .bss  : { *(.bss) } > ram
        
    _end = .;
    PROVIDE(_end = .);

    /DISCARD/ : { *(.comment) }

}

