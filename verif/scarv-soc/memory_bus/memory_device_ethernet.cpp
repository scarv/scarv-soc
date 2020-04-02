
#include "memory_device_ethernet.hpp"

bool memory_device_ethernet_transmit::read_word(
    memory_address addr,
    uint32_t     * dout
) {

    if (addr == this->addr_base + 0x07F4) {
        *dout = this->data_length;
    }

    return true;

}

bool memory_device_ethernet_transmit::write_byte(
    memory_address addr,
    uint8_t        data
) {

    if (addr >= this->addr_base && addr < this->addr_base + 6) {
        this->destination_address[addr - this->addr_base] = data;
    } else if (addr >= this->addr_base + 6 && addr < this->addr_base + 12) {
        this->source_address[addr - (this->addr_base + 6)] = data;
    } else if (addr >= this->addr_base + 12 && addr < this->addr_base + 14) {
        uint8_t *arr = (uint8_t *)&this->type_length;

        arr[addr - (this->addr_base + 12)] = data;
    } else if (addr >= this->addr_base + 14 && addr < this->addr_base + 1514) {
        this->data[addr - (this->addr_base + 14)] = data;
    } else if (addr >= this->addr_base + 0x07F4 && addr < this->addr_base + 0x07F4 + 4) {
        uint32_t offset = addr - (this->addr_base + 0x07F4);
        uint8_t *data_length = (uint8_t *)&(this->data_length);

        data_length[offset] = data;
    } else if (addr >= this->addr_base + 0x07F8 && addr < this->addr_base + 0x07F8 + 4) {
        uint32_t offset = addr - (this->addr_base + 0x07F8);
        uint8_t *gie = (uint8_t *)&(this->gie);

        gie[offset] = data;
    } else if (addr >= this->addr_base + 0x07FC && addr < this->addr_base + 0x07FC + 4) {
        uint32_t offset = addr - (this->addr_base + 0x07FC);
        uint8_t *control = (uint8_t *)&(this->control);

        control[offset] = data;

        if (data == 1 && offset == 0) {
            int result = this->eth_frame_send(
                "eth0", this->destination_address,
                this->data, this->data_length
            );

            if (result == 0) {
                this->control = 0;
            }
        }
    }

    return true;
    
}

uint8_t memory_device_ethernet_transmit::read_byte(
    memory_address addr
) {

    if (addr >= this->addr_base && addr < this->addr_base + 6) {
        return this->destination_address[addr - this->addr_base];
    } else if (addr >= this->addr_base + 6 && addr < this->addr_base + 12) {
        return this->source_address[addr - (this->addr_base + 6)];
    } else if (addr >= this->addr_base + 12 && addr < this->addr_base + 14) {
        uint8_t *arr = (uint8_t *)&this->type_length;

        return arr[addr - (this->addr_base + 12)];
    } else if (addr >= this->addr_base + 14 && addr < this->addr_base + 1514) {
        return this->data[addr - (this->addr_base + 14)];
    } else if (addr >= this->addr_base + 0x07F4 && addr < this->addr_base + 0x07F4 + 4) {
        uint32_t offset = addr - (this->addr_base + 0x07F4);
        uint8_t *data_length = (uint8_t *)&(this->data_length);

        return data_length[offset];
    } else if (addr >= this->addr_base + 0x07F8 && addr < this->addr_base + 0x07F8 + 4) {
        uint32_t offset = addr - (this->addr_base + 0x07F8);
        uint8_t *gie = (uint8_t *)&(this->gie);

        return gie[offset];
    } else if (addr >= this->addr_base + 0x07FC && addr < this->addr_base + 0x07FC + 4) {
        uint32_t offset = addr - (this->addr_base + 0x07FC);
        uint8_t *control = (uint8_t *)&(this->control);

        return control[offset];
    }

    return 0x4b;
    
}

// code taken from:
// https://hacked10bits.blogspot.com/2011/12/sending-raw-ethernet-frames-in-6-easy.html
int memory_device_ethernet_transmit::eth_frame_send(
    char *iface, unsigned char dest[ETH_ALEN],
    unsigned char *data, unsigned short data_len)
{
    unsigned short proto = 0x1234;
    
    int s;
    if ((s = socket(AF_PACKET, SOCK_RAW, htons(proto))) < 0) {
        printf("Error: could not open socket\n");
        return -1;
    }
    
    struct ifreq buffer;
    int ifindex;
    memset(&buffer, 0x00, sizeof(buffer));
    strncpy(buffer.ifr_name, iface, IFNAMSIZ);
    if (ioctl(s, SIOCGIFINDEX, &buffer) < 0) {
        printf("Error: could not get interface index\n");
        close(s);
        return -1;
    }
    ifindex = buffer.ifr_ifindex;
    
    unsigned char source[ETH_ALEN];
    if (ioctl(s, SIOCGIFHWADDR, &buffer) < 0) {
        printf("Error: could not get interface address\n");
        close(s);
        return -1;
    }
    memcpy((void*)source, (void*)(buffer.ifr_hwaddr.sa_data),
           ETH_ALEN);
    
    union ethframe frame;
    memcpy(frame.field.header.h_dest, dest, ETH_ALEN);
    memcpy(frame.field.header.h_source, source, ETH_ALEN);
    frame.field.header.h_proto = htons(proto);
    memcpy(frame.field.data, data, data_len);
    
    unsigned int frame_len = data_len + ETH_HLEN;
    
    struct sockaddr_ll saddrll;
    memset((void*)&saddrll, 0, sizeof(saddrll));
    saddrll.sll_family = PF_PACKET;   
    saddrll.sll_ifindex = ifindex;
    saddrll.sll_halen = ETH_ALEN;
    memcpy((void*)(saddrll.sll_addr), (void*)dest, ETH_ALEN);
    
    if (sendto(s, frame.buffer, frame_len, 0,
               (struct sockaddr*)&saddrll, sizeof(saddrll)) > 0) {
        printf("Success!\n");
    } else {
        printf("Error, could not send\n");
    }
    
    close(s);
    
    return 0;
}

bool memory_device_ethernet_receive::read_word(
    memory_address addr,
    uint32_t     * dout
) {

    return true;

}

bool memory_device_ethernet_receive::write_byte(
    memory_address addr,
    uint8_t        data
) {

    if (addr >= this->addr_base && addr < this->addr_base + 6) {
        this->destination_address[addr - this->addr_base] = data;
    } else if (addr >= this->addr_base + 6 && addr < this->addr_base + 12) {
        this->source_address[addr - (this->addr_base + 6)] = data;
    } else if (addr >= this->addr_base + 12 && addr < this->addr_base + 14) {
        uint8_t *arr = (uint8_t *)&this->type_length;

        arr[addr - (this->addr_base + 12)] = data;
    } else if (addr >= this->addr_base + 14 && addr < this->addr_base + 1514) {
        this->data[addr - (this->addr_base + 14)] = data;
    } else if (addr >= this->addr_base + 0x07F4 && addr < this->addr_base + 0x07F8) {
        uint32_t offset = addr - (this->addr_base + 0x07F4);
        uint8_t *arr = (uint8_t *)&(this->crc);

        arr[offset] = data;
    } else if (addr >= this->addr_base + 0x07F8 && addr < this->addr_base + 0x07FC) {
        uint32_t offset = addr - (this->addr_base + 0x07F8);
        uint8_t *arr = (uint8_t *)&(this->control);

        arr[offset] = data;
    }

    return true;
    
}

uint8_t memory_device_ethernet_receive::read_byte(
    memory_address addr
) {

    if (addr >= this->addr_base && addr < this->addr_base + 6) {
        return this->destination_address[addr - this->addr_base];
    } else if (addr >= this->addr_base + 6 && addr < this->addr_base + 12) {
        return this->source_address[addr - (this->addr_base + 6)];
    } else if (addr >= this->addr_base + 12 && addr < this->addr_base + 14) {
        uint8_t *arr = (uint8_t *)&this->type_length;

        return arr[addr - (this->addr_base + 12)];
    } else if (addr >= this->addr_base + 14 && addr < this->addr_base + 1514) {
        return this->data[addr - (this->addr_base + 14)];
    } else if (addr >= this->addr_base + 0x07F4 && addr < this->addr_base + 0x07F8) {
        uint32_t offset = addr - (this->addr_base + 0x07F4);
        uint8_t *arr = (uint8_t *)&(this->crc);

        return arr[offset];
    } else if (addr >= this->addr_base + 0x07F8 && addr < this->addr_base + 0x07FC) {
        uint32_t offset = addr - (this->addr_base + 0x07F8);
        uint8_t *arr = (uint8_t *)&(this->control);

        if (offset == 0 && this->control == 0) {
            int result = this->eth_frame_recv(
                "eth0", this->source_address, this->destination_address,
                this->data
            );

            if (result > 0) {
                this->control = 1;
            }
        }

        return arr[offset];
    }

    return 0x4b;
}

int memory_device_ethernet_receive::eth_frame_recv(
    char *iface,
    uint8_t source[ETH_ALEN], uint8_t dest[ETH_ALEN], uint8_t *data)
{
    union ethframe frame;
    
    struct sockaddr_ll saddrll;
    memset((void *)&saddrll, 0, sizeof(saddrll));

    socklen_t sll_len = (socklen_t)sizeof(saddrll);

    int recv_result = recvfrom(
        this->r_socket, frame.buffer, ETH_FRAME_LEN, 0,
        (struct sockaddr *)&saddrll, &sll_len
    );
    
    if (recv_result > 0) {
        memcpy(data, frame.field.data, ETH_DATA_LEN);

        memcpy(source, frame.field.header.h_source, ETH_ALEN);
        memcpy(dest, frame.field.header.h_dest, ETH_ALEN);

        return 1;
    } else {
        return recv_result;
    }
}
