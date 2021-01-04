
#include <assert.h>
#include <iostream>
#include <fstream>

#include "dut_wrapper.hpp"

/*!
*/
dut_wrapper::dut_wrapper (
    bool            dump_waves  ,
    std::string     wavefile
){

    this -> dut                    = new Vscarv_soc();

    this -> dump_waves             = dump_waves;
    this -> vcd_wavefile_path      = wavefile;

    Verilated::traceEverOn(this -> dump_waves);

    if(this -> dump_waves){
        this -> trace_fh = new VerilatedVcdC;
        this -> dut -> trace(this -> trace_fh, 99);
        this -> trace_fh -> open(this ->vcd_wavefile_path.c_str());
    }

    this -> sim_time               = 0;

    this -> uart = new agent_uart (
        &this -> dut -> uart_txd,
        &this -> dut -> uart_rxd
    );
    this -> uart -> print_rx = false;

}
   

//! Put the dut in reset.
void dut_wrapper::dut_set_reset() {

    // Put model in reset.
    this -> dut -> sys_reset    = 1;
    this -> dut -> f_clk        = 0;
    this -> uart-> on_set_reset();

}
    
//! Take the DUT out of reset.
void dut_wrapper::dut_clear_reset() {
    
    this -> dut -> f_clk_locked = 1;
    this -> dut -> sys_reset= 0;
    this -> uart-> on_clear_reset();
    
}


//! Simulate the DUT for a single clock cycle
void dut_wrapper::dut_step_clk() {

    vluint8_t prev_clk;

    for(uint32_t i = 0; i < this -> evals_per_clock; i++) {

        prev_clk = this -> dut -> f_clk;
        
        if(i == this -> evals_per_clock / 2) {
            
            this -> dut -> f_clk = !this -> dut -> f_clk;
            
            if(this -> dut -> f_clk == 1){

                this -> posedge_fclk();
            }
       
        } 
        
        this -> dut -> eval();

        this -> sim_time ++;

        if(this -> dump_waves) {
            this -> trace_fh -> dump(this -> sim_time);
        }

        this -> uart -> poll_pseudo_terminal();
        this -> uart -> empty_rx_queue();

    }

}


void dut_wrapper::posedge_fclk () {
    
    this -> uart -> on_posedge_clk();
    
    // Do we need to capture a trace item?
    if(this -> dut -> trs_valid) {
        this -> dut_trace.push (
            {
                this -> dut -> trs_pc,
                this -> dut -> trs_instr
            }
        );
    }

}

