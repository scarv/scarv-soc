
#include <cstdlib>
#include <cassert>
#include <cstdio>

#include <iostream>
#include <queue>

#include <unistd.h>
#include <fcntl.h>

#include "memory_device.hpp"

#ifndef MEMORY_DEVICE_GPIO_HPP
#define MEMORY_DEVICE_GPIO_HPP

#define MEMORY_DEVICE_GPIO_RANGE 0x10

/*!
@brief A basic GPIO device
@details:
Register Map:
Offset  |  Register
--------|----------------------
0x0     | DATA
0x4     | TRI
0x8     | DATA2
0xC     | TRI2   
*/
class memory_device_gpio : public memory_device {

public:
    
    memory_device_gpio (
        memory_address base
    ) : memory_device(base,MEMORY_DEVICE_GPIO_RANGE) {

        addr_gpio_data  = base + 0x00;
        addr_gpio_tri   = base + 0x04;
        addr_gpio2_data = base + 0x08;
        addr_gpio2_tri  = base + 0x0C;

    }

    ~memory_device_gpio(){

    }

    /*!
    @brief Read a word from the address given.
    @returns true if the read succeeds. False otherwise.
    */
    bool read_word (
        memory_address addr,
        uint32_t     * dout
    );

    /*!
    @brief Write a single byte to the device.
    @return true if the write is in range, else false.
    */
    bool write_byte (
        memory_address addr,
        uint8_t        data
    );


    /*!
    @brief Return a single byte from the device.
    */
    uint8_t read_byte (
        memory_address addr
    );

protected:
    
    // Addresses of each register, calculated at instantiation.
    memory_address addr_gpio_data;
    memory_address addr_gpio_tri ;
    memory_address addr_gpio2_data;
    memory_address addr_gpio2_tri ;
    
    // Contents of each register.
    uint32_t reg_gpio_data ;
    uint32_t reg_gpio_tri  ;
    uint32_t reg_gpio2_data;
    uint32_t reg_gpio2_tri ;
    
};

#endif

