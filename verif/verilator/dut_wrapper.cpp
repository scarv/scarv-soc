
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

}
   

//! Put the dut in reset.
void dut_wrapper::dut_set_reset() {

    // Put model in reset.
    this -> dut -> g_resetn     = 0;
    this -> dut -> f_clk        = 0;

}
    
//! Take the DUT out of reset.
void dut_wrapper::dut_clear_reset() {
    
    this -> dut -> g_resetn = 1;
    
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

    }

}


void dut_wrapper::posedge_fclk () {
    
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

