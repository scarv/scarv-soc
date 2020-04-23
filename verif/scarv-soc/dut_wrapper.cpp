
#include <assert.h>
#include <iostream>
#include <fstream>

#include "dut_wrapper.hpp"

/*!
*/
dut_wrapper::dut_wrapper (
    memory_bus    * bus         ,
    bool            dump_waves  ,
    std::string     wavefile
){

    this -> bus                    = bus;

    this -> dut                    = new Vscarv_soc();

    this -> axi_agent              = new a4l_slave_agent(
        &dut -> m0_awvalid      , //
        &dut -> m0_awready      , //
        &dut -> m0_awaddr       , //
        &dut -> m0_awprot       , //
        &dut -> m0_wvalid       , //
        &dut -> m0_wready       , //
        &dut -> m0_wdata        , //
        &dut -> m0_wstrb        , //
        &dut -> m0_bvalid       , //
        &dut -> m0_bready       , //
        &dut -> m0_bresp        , //
        &dut -> m0_arvalid      , //
        &dut -> m0_arready      , //
        &dut -> m0_araddr       , //
        &dut -> m0_arprot       , //
        &dut -> m0_rvalid       , //
        &dut -> m0_rready       , //
        &dut -> m0_rresp        , //
        &dut -> m0_rdata          //
    );

    this -> axi_agent -> set_bus_model(this -> bus);

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
    this -> dut -> g_clk        = 0;
    
    this -> axi_agent -> set_reset();

}
    
//! Take the DUT out of reset.
void dut_wrapper::dut_clear_reset() {
    
    this -> dut -> g_resetn = 1;
    
    this -> axi_agent -> clr_reset();

}


//! Simulate the DUT for a single clock cycle
void dut_wrapper::dut_step_clk() {

    vluint8_t prev_clk;

    for(uint32_t i = 0; i < this -> evals_per_clock; i++) {

        prev_clk = this -> dut -> g_clk;
        
        if(i == this -> evals_per_clock / 2) {
            
            this -> dut -> g_clk = !this -> dut -> g_clk;
            
            if(this -> dut -> g_clk == 1){

                this -> posedge_gclk();
            }
       
        } 
        
        this -> dut -> eval();

        this -> sim_time ++;

        if(this -> dump_waves) {
            this -> trace_fh -> dump(this -> sim_time);
        }

    }

}


void dut_wrapper::posedge_gclk () {
    
    // Do we need to capture a trace item?
    if(this -> dut -> scarv_soc -> cpu_trs_valid) {
        this -> dut_trace.push (
            {
                this -> dut -> scarv_soc -> cpu_trs_pc,
                this -> dut -> scarv_soc -> cpu_trs_instr
            }
        );
    }

    this -> axi_agent -> on_posedge_clk();

}

void dut_wrapper::set_ext_interrupt(int cause) {

    this -> dut -> cpu_int_ext_cause = cause;
    this -> dut -> cpu_int_external = 1;

    printf(
        "dut ext %d, dut cause %d, soc ext %d, soc cause %d\n",
        this -> dut -> cpu_int_external,
        this -> dut -> cpu_int_ext_cause,
        this -> dut -> scarv_soc -> cpu_int_external,
        this -> dut -> scarv_soc -> cpu_int_ext_cause
    );

}

void dut_wrapper::clear_ext_interrupt() {

    this -> dut -> cpu_int_external = 0;
    this -> dut -> cpu_int_ext_cause = 0;

    printf(
        "dut ext %d, dut cause %d\n",
        this -> dut -> cpu_int_external,
        this -> dut -> cpu_int_ext_cause
    );
}
