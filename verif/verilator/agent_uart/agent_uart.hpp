
#include <stdio.h>
#include <stdint.h>
#include <queue>
#include <cassert>
#include <iostream>

// For Linux I/O
#include <unistd.h>
#include <fcntl.h>

#ifndef __AGENT_UART_HPP__
#define __AGENT_UART_HPP__



//! A UART agent for communicating with a DUT over UART.
class agent_uart {

public:
    
    //! Bit rate of the UART device.
    uint32_t    baud_rate = 115200;
    
    //! Stop bits per packet.
    uint32_t    stop_bits = 1;
    
    //! Frequency of the UART clock in Hertz.
    uint32_t    clock_rate = 50000000; // 50MHz

    //! Size in bits of things to send/recieve.
    const int   payload_size = 8;

    //! If true, print recieved characters to stdout.
    bool        print_rx = true;
    
    //! Create a new UART agent.
    agent_uart (
        uint8_t * rx, // Recive line wrt agent. (input)
        uint8_t * tx  // Transmit line wrt agent. (output)
    );
    
    ~agent_uart(){
        if(this -> pseudo_term_open) {
            close(pseudo_term_handle);
        }
    }

    std::queue<uint8_t> rx_q; // Recieved bytes.
    std::queue<uint8_t> tx_q; // Bytes to be sent.

    //! Called by the testbench to put the agent in reset.
    void on_set_reset();
    
    //! Called by the testbench to take the agent out of reset.
    void on_clear_reset();

    //! Called by the testbench on the rising edge of every clock.
    void on_posedge_clk();

    //! Send the supplied data on the TX line.
    void send(uint8_t * data, size_t len);
    
    //! Empty the recieved data queue.
    void empty_rx_queue();

    enum state_rx {
        RX_IDLE, RX_START, RX_RECV, RX_STOP
    };
    
    enum state_tx {
        TX_IDLE, TX_START, TX_SEND, TX_STOP
    };

    //! Read any data from the pseudo terminal.
    void poll_pseudo_terminal();

private:

    bool      in_reset = true;

    uint8_t * rx; // Recive line wrt agent. (input)
    uint8_t * tx; // Transmit line wrt agent. (output)

    uint32_t bit_period;    //!< Time in nanoseconds for a single bit.
    uint32_t clk_period;    //!< Clock period in nanoseconds.
    uint32_t clk_per_bit;   //!< Clock cycles per transmitted bit.

    uint32_t clk_counter_rx;//!< Counter for sampling.
    uint32_t clk_counter_tx;//!< Counter for transmitting.
    uint32_t bit_counter_rx;//!< Counter for sampling.
    uint32_t bit_counter_tx;//!< Counter for transmitting.

    uint64_t clk_ticks; //!< Clock ticks since last reset.

    uint8_t  rx_bits ; //!< Byte currently being recieved.
    uint8_t  tx_bits ; //!< Byte currently being transmitted.

    agent_uart::state_rx rx_state;
    agent_uart::state_tx tx_state;

    void handle_rx();
    void handle_tx();

    //! Used to provide a virtual serial port.
    int pseudo_term_handle;

    //! Did the pseudo terminal open successfully?
    bool pseudo_term_open = false;

    //! Name of the slave pseudo terminal.
    char * pseudo_term_slave;

    //! Initialises the pseudo terminal.
    void setup_pseudo_terminal();

};

#endif
