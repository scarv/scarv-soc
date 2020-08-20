
#include "agent_uart.hpp"

//! One second in nanosecond.
static const uint32_t S_NS = 1000000000;

agent_uart::agent_uart (
    uint8_t * rx, // Recive line wrt agent. (input)
    uint8_t * tx  // Transmit line wrt agent. (output)
) {
    this -> rx = rx;
    this -> tx = tx;

    this -> setup_pseudo_terminal();
}


//! Called by the testbench to put the agent in reset.
void agent_uart::on_set_reset() {
    this -> bit_period      = 0;
    this -> clk_period      = 0;
    this -> clk_per_bit     = 0;
    this -> clk_counter_rx  = 0;
    this -> clk_counter_tx  = 0;
    this -> rx_state        = RX_IDLE;
    this -> tx_state        = TX_IDLE;
    this -> clk_ticks       = 0;
    this -> in_reset        = true;

    *tx = 1;
}

//! Called by the testbench to take the agent out of reset.
void agent_uart::on_clear_reset() {
    this -> bit_period      = S_NS / this -> baud_rate;
    this -> clk_period      = S_NS / this -> clock_rate;
    this -> clk_per_bit     = this -> bit_period / this -> clk_period;
    this -> in_reset        = false;

    *tx = 1;

    //printf(">> UART Baud    : %d\n", this -> baud_rate);
    //printf(">> UART Clk/Bit : %d\n", this -> clk_per_bit);
}


//! Called by the testbench on the rising edge of every clock.
void agent_uart::on_posedge_clk() {

    if(in_reset) {return;}

    handle_rx();
    handle_tx();

    this -> clk_ticks ++;

}
    
//! Send the supplied data on the TX line.
void agent_uart::send(uint8_t * data, size_t len){
    for(size_t i = 0; i < len; i++) {
        this -> tx_q.push(data[i]);
    }
}
    
//! Empty the recieved data queue.
void agent_uart::empty_rx_queue() {
    while(not this -> rx_q.empty()) {
        this -> rx_q.pop();
    }
}
    
void agent_uart::handle_rx() {

    if(this -> rx_state == RX_IDLE) {                       // IDLE

        if(*rx) {
            // Stay Idle.
            this -> rx_state        = RX_IDLE; 
        } else {
            // Start bit seen. Reset counters and move to start state.
            this -> rx_state        = RX_START;
            this -> rx_bits         = 0;
            this -> clk_counter_rx  = 0;
            this -> bit_counter_rx  = 0;
        }

    } else if(this -> rx_state == RX_START) {               // START BIT

        this -> clk_counter_rx ++;
        this -> bit_counter_rx  = 0;

        if(this -> clk_counter_rx >= clk_per_bit) {
            this -> clk_counter_rx  = 0;
            this -> rx_state        = RX_RECV;
        } else {
            this -> rx_state        = RX_START;
        }

    } else if(this -> rx_state == RX_RECV) {                // RECV
    
        this -> clk_counter_rx ++;

        if(this -> clk_counter_rx == (clk_per_bit / 2)) {
            // Sample current bit in middle of symbol.
            rx_bits |= ((*rx & 0x1) << this->bit_counter_rx);
        }

        if(this -> clk_counter_rx >= clk_per_bit) {
            // Increment bit counter and reset clock counter.
            this -> clk_counter_rx = 0;
            this -> bit_counter_rx ++ ;
        }

        if(this -> bit_counter_rx >= payload_size) {
            // Move to stop bit state
            this -> rx_state        = RX_STOP;
            this -> clk_counter_rx  = 0;

            // Push sampled value.
            this -> rx_q.push(this -> rx_bits);

            // Print it?
            if(this -> print_rx) {
                printf("%c", this -> rx_bits);
                fflush(stdout);
            }

            this -> rx_bits = 0;
        }

    } else if(this -> rx_state == RX_STOP) {                // STOP BIT
        
        this -> clk_counter_rx ++;

        if(this -> clk_counter_rx == clk_per_bit) {
            // Return to idle.
            this -> clk_counter_rx  = 0;
            this -> rx_state        = RX_IDLE;
        }

    }

}

void agent_uart::handle_tx() {
    
    if(this -> tx_state == TX_IDLE) {                       // IDLE

        *tx = 1;

        if(tx_q.empty()) {
            // Stay Idle.
            this -> tx_state        = TX_IDLE; 
        } else {
            // Start bit seen. Reset counters and move to start state.
            this -> tx_state        = TX_START;
            this -> tx_bits         = tx_q.front();
            tx_q.pop();
            this -> clk_counter_tx  = 0;
            this -> bit_counter_tx  = 0;
        }

    } else if(this -> tx_state == TX_START) {               // START BIT
        
        *tx = 0;

        this -> clk_counter_tx ++;

        if(this -> clk_counter_tx >= clk_per_bit) {
            this -> bit_counter_tx  = 0;
            this -> clk_counter_tx  = 0;
            this -> tx_state        = TX_SEND;
        } else {
            this -> tx_state        = TX_START;
        }

    } else if(this -> tx_state == TX_SEND) {                // SEND

        *tx = this -> tx_bits & 0x01;
    
        this -> clk_counter_tx ++;

        if(this -> clk_counter_tx >= clk_per_bit) {
            // Increment bit counter and reset clock counter.
            this -> clk_counter_tx = 0;
            this -> bit_counter_tx ++ ;
            this -> tx_bits >>= 1;
        }

        if(this -> bit_counter_tx >= payload_size) {
            // Move to stop bit state
            this -> tx_state        = TX_STOP;
            this -> clk_counter_tx  = 0;
        }

    } else if(this -> tx_state == TX_STOP) {                // STOP BIT
        
        *tx = 1;
        
        this -> clk_counter_tx ++;

        if(this -> clk_counter_tx == clk_per_bit) {
            // Return to idle.
            this -> clk_counter_tx  = 0;
            this -> tx_state        = TX_IDLE;
        }

    }

}


void agent_uart::setup_pseudo_terminal() {

    int status;

    pseudo_term_handle = posix_openpt(O_RDWR|O_NOCTTY|O_SYNC|O_NONBLOCK);

    status = grantpt(pseudo_term_handle);
    assert(status>=0);

    status = unlockpt(pseudo_term_handle);
    assert(status>=0);

    pseudo_term_slave = ptsname(pseudo_term_handle);

    std::cout<<">> Open UART at: " << pseudo_term_slave <<std::endl;

    pseudo_term_open = true;
}

void agent_uart::poll_pseudo_terminal() {

    if(pseudo_term_open) {
        
        // Add data from the pseudo terminal to the rx buffer.
        uint8_t read_data [1];

        size_t count = read(pseudo_term_handle, read_data, 1);

        if(count == 1) {
            this -> send(read_data, 1);
        }

        while( not this -> rx_q.empty()) {
            uint8_t tosend[1];
            tosend[0] = this -> rx_q.front();
            size_t x=write(
                this -> pseudo_term_handle,
                tosend, 1
            );
            this -> rx_q.pop();
        }
    }

}

