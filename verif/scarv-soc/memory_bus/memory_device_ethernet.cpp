
#include "memory_device_ethernet.hpp"

bool memory_device_ethernet_transmit::read_word(
    memory_address addr,
    uint32_t     * dout
) {

    printf("t: reading word %08lx\n", addr);

    if (addr == this->addr_base + 0x07F4) {
        *dout = this->data_length;
    }

    return true;

}

bool memory_device_ethernet_transmit::write_byte(
    memory_address addr,
    uint8_t        data
) {

    printf("t: writing byte %08lx <- %02x\n", addr, data);

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
    }

    return true;
    
}

uint8_t memory_device_ethernet_transmit::read_byte(
    memory_address addr
) {

    printf("t: reading byte %08lx\n", addr);

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

bool memory_device_ethernet_receive::read_word(
    memory_address addr,
    uint32_t     * dout
) {

    printf("r: reading word %08lx\n", addr);

    return true;

}

bool memory_device_ethernet_receive::write_byte(
    memory_address addr,
    uint8_t        data
) {

    printf("r: writing byte %08lx <- %02x\n", addr, data);

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

    printf("r: reading byte %08lx\n", addr);

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

        return arr[offset];
    }

    return 0x4b;
}
