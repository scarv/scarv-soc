
#include "memory_device_gpio.hpp"


/*!
*/
bool memory_device_gpio::read_word (
    memory_address addr,
    uint32_t     * dout
){
    if(addr == addr_gpio_data) {
        dout = &reg_gpio_data;
    }
    else if(addr == addr_gpio_tri) {
        dout = &reg_gpio_tri;
    }
    else if(addr == addr_gpio2_data) {
        dout = &reg_gpio2_data;
    }
    else if(addr == addr_gpio2_tri) {
        dout = &reg_gpio2_tri;
    }
    else {
        return false;
    }
    return true;
}


/*!
*/
bool memory_device_gpio::write_byte (
    memory_address addr,
    uint8_t        data
){
    int byte = (addr & 0x3)*8;

    uint32_t tw   = (uint32_t)data << byte;
    uint32_t mask = ~(0xFF << byte);

    if(addr == addr_gpio_data) {
        reg_gpio_data = (reg_gpio_data & mask) | tw;
    }
    else if(addr == addr_gpio_tri) {
        reg_gpio_tri  = (reg_gpio_tri  & mask) | tw;
    }
    else if(addr == addr_gpio2_data) {
        reg_gpio2_data = (reg_gpio2_data & mask) | tw;
    }
    else if(addr == addr_gpio2_tri) {
        reg_gpio2_tri  = (reg_gpio2_tri  & mask) | tw;
    }
    else {
        return false;
    }
    return true;
}


/*!
@brief Return a single byte from the device.
*/
uint8_t memory_device_gpio::read_byte (
    memory_address addr
){
    int byte = (addr & 0x3)*8;

    if(addr == addr_gpio_data) {
        return (reg_gpio_data   >> byte) & 0xFF;
    }
    else if(addr == addr_gpio_tri) {
        return (reg_gpio_tri    >> byte) & 0xFF;
    }
    else if(addr == addr_gpio2_data) {
        return (reg_gpio2_data  >> byte) & 0xFF;
    }
    else if(addr == addr_gpio2_tri) {
        return (reg_gpio2_tri   >> byte) & 0xFF;
    }
    else {
        return 0;
    }
}

