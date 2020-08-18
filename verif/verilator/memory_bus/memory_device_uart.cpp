
#include "memory_device_uart.hpp"


void memory_device_uart::setup_pseudo_terminal() {

    int status;

    pseudo_term_handle = posix_openpt(O_RDWR | O_NOCTTY | O_SYNC | O_NONBLOCK);

    status = grantpt(pseudo_term_handle);
    assert(status>=0);

    status = unlockpt(pseudo_term_handle);
    assert(status>=0);

    pseudo_term_slave = ptsname(pseudo_term_handle);

    std::cout<<">> Open Slave UART at: " << pseudo_term_slave <<std::endl;

    pseudo_term_open = true;
}

/*!
*/
bool memory_device_uart::read_word (
    memory_address addr,
    uint32_t     * dout
){

    std::cout << "UART ";

    if (addr == addr_tx) {
        dout = &reg_tx;
    }
    else if (addr == addr_rx) {
        dout = &reg_rx;
        std::cout << "Read RX"<<std::endl;
    }
    else if(addr == addr_ctrl) {
        std::cout << "Read CTRL"<<std::endl;
        dout = &reg_ctrl;
    }
    else if(addr == addr_status) {
    
        poll_pseudo_terminal();

        reg_status = 
            (tx_buffer.size() >= tx_buf_depth) << 3 |
            (tx_buffer.size() ==            0) << 2 |
            (rx_buffer.size() !=            0) << 0 ;

        dout = &reg_status;
        std::cout << "Read STATUS"<<std::endl;
    }
    else {
        return false;
    }

    return true;
}


/*!
*/
bool memory_device_uart::write_byte (
    memory_address addr,
    uint8_t        data
){

    memory_address word_addr = addr & ~(0b11);
    
    if(addr == addr_tx){
        if((addr & 0b11) == 0) {
            // Only send iff writing to lowest byte of the register.
            write_to_tx_buffer(data);
        }
    }
    else if (addr == addr_rx){
        // Do nothing. It makes no sense to write to the RX buffer.
    }
    else if (addr == addr_ctrl){
        std::cerr << "__FILE__:__LINE__ - UART Register not implemented."
                  << std::endl;
        return false;
    }
    else if (addr == addr_status){
        
        // Do nothing. register is read only.

    }
    else {

        return false;

    }

    return true;
}


/*!
@brief Return a single byte from the device.
*/
uint8_t memory_device_uart::read_byte (
    memory_address addr
){
    memory_address word_addr = addr & ~(0b11);
    memory_address byte_off  = addr &  (0b11);

    if(addr == addr_tx){
        
        if(addr & 0b11 == 0) {
            
            return reg_tx&0xFF;

        }

        return 0;

    }
    else if(addr == addr_rx){
        
        reg_rx = get_from_rx_buffer();
        return byte_off == 0 ? reg_rx : 0;

    }
    else if(addr == addr_ctrl){

        std::cerr << "__FILE__:__LINE__ - UART Register not implemented."
                  << std::endl;

    }
    else if(addr == addr_status){
    
        poll_pseudo_terminal();

        reg_status = 
            (tx_buffer.size() >= tx_buf_depth) << 3 |
            (tx_buffer.size()  ==           0) << 2 |
            (rx_buffer.size()  >            0) << 0 ;

        return byte_off == 0 ? reg_status : 0;

    }
    else {

        return 0;

    }
}

void memory_device_uart::poll_pseudo_terminal() {

    if(pseudo_term_open) {
        
        // Add data from the pseudo terminal to the rx buffer.
        char  read_data [1];

        size_t count = read(pseudo_term_handle, read_data, 1);

        if(count == 1) {
            rx_buffer.push(read_data[0]);
        }

    }

}

//! Get the next char from the rx buffer and pop it from the buffer.
uint8_t memory_device_uart::get_from_rx_buffer() {

    poll_pseudo_terminal();

    if(rx_buffer.empty() == false) {

        uint8_t tr = rx_buffer.front();
        rx_buffer.pop();
        return tr;

    } else {
        
        return 0;

    }

}

//! Get the next char from the rx buffer and pop it from the buffer.
void memory_device_uart::write_to_tx_buffer(uint8_t data) {

    if(pseudo_term_open) {

        char tosend [1];
        tosend[0] = data;

        // Send the data to the pseudo terminal.
        write(pseudo_term_handle, tosend, 1);

    } else {
    
        tx_buffer.push(data);

        // Just print stuff to STDOUT.
        // Line buffered - so if we see a newline, print and empty the buffer.
        if(data == '\n') {

            std::cout << "$ ";
            
            while(tx_buffer.size() > 0) {
                std::cout << tx_buffer.front();
                tx_buffer.pop();
            }

            tx_buffer.empty();
        }

    }

}
