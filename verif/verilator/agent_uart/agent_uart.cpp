
#include "agent_uart.hpp"

//! One second in nanosecond.
static const uint32_t S_NS = 1000000000;

agent_uart::agent_uart (
    uint8_t * rx, // Recive line wrt agent. (input)
    uint8_t * tx  // Transmit line wrt agent. (output)
) {
    this -> rx = rx;
    this -> tx = tx;
}


//! Called by the testbench to put the agent in reset.
void agent_uart::on_set_reset() {
    this -> bit_period      = 0;
    this -> clk_period      = 0;
    this -> clk_per_bit     = 0;
    this -> clk_counter_rx  = 0;
    this -> clk_counter_tx  = 0;
    this -> rx_state        = RX_IDLE;
    this -> clk_ticks       = 0;
    this -> in_reset        = true;
}

//! Called by the testbench to take the agent out of reset.
void agent_uart::on_clear_reset() {
    this -> bit_period      = S_NS / this -> baud_rate;
    this -> clk_period      = S_NS / this -> clock_rate;
    this -> clk_per_bit     = this -> bit_period / this -> clk_period;
    this -> in_reset        = false;

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

}
