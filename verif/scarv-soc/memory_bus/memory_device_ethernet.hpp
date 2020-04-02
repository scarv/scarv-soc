#include <cstdlib>
#include <cassert>
#include <cstdio>

#include <iostream>
#include <queue>

#include <unistd.h>
#include <fcntl.h>

// networking includes
#include <string.h>
#include <sys/socket.h>    /* Must precede if*.h */
#include <linux/if.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>

#include "memory_device.hpp"

#ifndef MEMORY_DEVICE_ETHERNET_HPP
#define MEMORY_DEVICE_ETHERNET_HPP

union ethframe
{
  struct
  {
    struct ethhdr    header;
    unsigned char    data[ETH_DATA_LEN];
  } field;
  unsigned char    buffer[ETH_FRAME_LEN];
};

class memory_device_ethernet_transmit : public memory_device {

public:
    
    memory_device_ethernet_transmit(
        memory_address base,
        size_t         range
    ) : memory_device(base, range) {

    }

    bool read_word(memory_address addr, uint32_t *dout);

    bool write_byte(memory_address addr, uint8_t data);

    uint8_t read_byte(memory_address addr);

    int eth_frame_send(
        char *iface, unsigned char dest[ETH_ALEN],
        unsigned char *data, unsigned short data_len
    );

protected:

    uint8_t destination_address[6];
    uint8_t source_address[6];
    uint16_t type_length;
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
        unsigned short proto = 0x1234;

        this->r_socket = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
        
        if (this->r_socket < 0) {
            printf("Error: could not open socket\n");
        } else {
            printf("Successfully initialised the socket\n");
        }

        // set the socket to be non-blocking
        int flags = fcntl(this->r_socket, F_GETFL);

        fcntl(this->r_socket, F_SETFL, flags | O_NONBLOCK);
    }

    ~memory_device_ethernet_receive() {
        printf("Closing socket\n");

        close(this->r_socket);
    }

    bool read_word(
        memory_address addr,
        uint32_t     * dout
    );

    bool write_byte(
        memory_address addr,
        uint8_t        data
    );

    uint8_t read_byte(
        memory_address addr
    );

    int eth_frame_recv(
        char *iface,
        uint8_t source[ETH_ALEN], uint8_t dest[ETH_ALEN], uint8_t *data
    );

protected:

    int r_socket;
    int ifindex;
    uint8_t destination_address[6];
    uint8_t source_address[6];
    uint16_t type_length;
    uint8_t data[1500];
    uint32_t crc;
    uint32_t control;

};

#endif

