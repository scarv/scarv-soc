
#include "memory_device_ethernet.hpp"


bool memory_device_ethernet::read_word(
    memory_address addr,
    uint32_t     * dout
) {

    printf("reading word %08lx\n", addr);

    return true;

}

bool memory_device_ethernet::write_byte(
    memory_address addr,
    uint8_t        data
) {

    printf("writing byte %08lx <- %02x\n", addr, data);

    return true;
    
}

uint8_t memory_device_ethernet::read_byte(
    memory_address addr
) {

    printf("reading byte %08lx\n", addr);

    return 0x4b;
    
}
