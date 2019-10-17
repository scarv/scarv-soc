
#include "testbench.hpp"


//! Construct all of the objects we need inside the testbench.
void testbench::build() {

    this -> dut = new dut_wrapper(
        this -> waves_dump,
        this -> waves_file
    );

}
    
//! Called immediately before the run function.
void testbench::pre_run() {

    this -> dut -> dut_set_reset();

    // Run the DUT for a few cycles while held in reset.
    for(int i = 0; i < 5; i ++) {
        dut -> dut_step_clk();
    }

}

//! The main phase of the DUT simulation.
void testbench::run() {
    
    // Start running the DUT proper.
    dut -> dut_clear_reset();

    while(dut -> get_sim_time() < max_sim_time && !sim_finished) {
        
        dut -> dut_step_clk();

    }

}

//! Called after the run function has returned.
void testbench::post_run() {
    
    if(this -> waves_dump) {
        dut -> trace_fh -> close();
    }

}

