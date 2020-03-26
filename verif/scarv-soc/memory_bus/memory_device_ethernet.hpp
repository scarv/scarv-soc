
#include <cstdlib>
#include <cassert>
#include <cstdio>

#include <iostream>
#include <queue>

#include <unistd.h>
#include <fcntl.h>

#include "memory_device.hpp"

#ifndef MEMORY_DEVICE_ETHERNET_HPP
#define MEMORY_DEVICE_ETHERNET_HPP

class memory_device_ethernet_transmit : public memory_device {

public:
    
    memory_device_ethernet_transmit(
        memory_address base,
        size_t         range
    ) : memory_device(base, range) {

    }

    bool read_word (
        memory_address addr,
        uint32_t     * dout
    );

    bool write_byte (
        memory_address addr,
        uint8_t        data
    );

    uint8_t read_byte (
        memory_address addr
    );

protected:

    uint8_t destination_address[6];
    uint8_t source_address[6];
    uint8_t type_length[2];
    uint8_t data[1500];
    uint32_t data_length;
    uint32_t gie;
    uint32_t control;

};

class memory_device_ethernet_receive : public memory_device {

public:
    
    memory_device_ethernet_receive(
        memory_address base,
        size_t         range
    ) : memory_device(base, range) {

    }

    bool read_word (
        memory_address addr,
        uint32_t     * dout
    );

    bool write_byte (
        memory_address addr,
        uint8_t        data
    );

    uint8_t read_byte (
        memory_address addr
    );

protected:

    uint8_t destination_address[6];
    uint8_t source_address[6];
    uint8_t type_length[2];
    uint8_t data[1500];
    uint32_t crc;
    uint32_t control;

};

class memory_device_ethernet : public memory_device {

public:
    
    memory_device_ethernet(
        memory_address base,
        size_t         range
    ) : memory_device(base, range) {

    }

    bool read_word (
        memory_address addr,
        uint32_t     * dout
    );

    bool write_byte (
        memory_address addr,
        uint8_t        data
    );

    uint8_t read_byte (
        memory_address addr
    );

protected:

    memory_device_ethernet_transmit transmit;
    memory_device_ethernet_receive receive;

};

#endif

