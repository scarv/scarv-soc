
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

//! Drain the DUT trace queue from the DUT wrapper and process as needed.
void testbench::drain_dut_trace() {

    while (dut -> dut_trace.size()) {

        dut_trace_pkt_t packet = dut -> dut_trace.front();

        if(this -> use_sim_pass_address &&
           this -> sim_pass_address     == packet.program_counter) {

            this -> sim_finished = true;
            this -> sim_passed   = true;

        }

        if(this -> use_sim_fail_address &&
           this -> sim_fail_address     == packet.program_counter) {

            this -> sim_finished = true ;
            this -> sim_passed   = false;

        }

        dut -> dut_trace.pop();

    }

}


//! The main phase of the DUT simulation.
void testbench::run() {
    
    // Start running the DUT proper.
    dut -> dut_clear_reset();

    while(dut -> get_sim_time() < max_sim_time && !sim_finished) {
        
        dut -> dut_step_clk();

        this -> drain_dut_trace();

    }

}

//! Called after the run function has returned.
void testbench::post_run() {
    
    if(this -> waves_dump) {
        dut -> trace_fh -> close();
    }

    sim_finished = true;

}

