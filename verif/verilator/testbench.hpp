
#ifndef TESTBENCH_HPP
#define TESTBENCH_HPP

#include "dut_wrapper.hpp"

class testbench {

public:
    
    //! Create a new testbench.
    testbench (
        std::string waves_file,
        bool        waves_dump
    ) {
        
        this -> waves_file = waves_file;
        this -> waves_dump = waves_dump;

        this -> build();
    }

    //! The design under test.
    dut_wrapper * dut;

    //! Run the simulation from beginning to end.
    void run_simulation() {
        if(wait_at_start) {
            std::string dummy;
            std::cout << ">> Press return to begin simulation:" << std::endl;
            std::getline(std::cin,dummy);
        }
        this -> pre_run();   
        this -> run();   
        this -> post_run();
    }

    uint64_t        max_sim_time     =  10000;

    //! Return total simulation time so far.
    uint64_t get_sim_time() {
        return this -> dut -> get_sim_time();
    }

    //! Has the simulation finished running yet?
    bool     sim_finished    = false;

    //! Did the simulation meet it's pass criterion?
    bool     sim_passed      = false;

    //! Set the simulation pass address.
    void     set_pass_address (uint32_t addr) {
        this -> sim_pass_address     = addr;
        this -> use_sim_pass_address = true;
    }

    //! Set the simulation fail address.
    void     set_fail_address (uint32_t addr) {
        this -> sim_fail_address     = addr;
        this -> use_sim_fail_address = true;
    }

    //! Wait for a keypress after building TB but before running the sim.
    bool           wait_at_start        = false;

protected:

    //! Address which if hit causes the simulation to pass immediately.
    uint32_t        sim_pass_address;

    //! Address which if hit causes the simulation to fail immediately.
    uint32_t        sim_fail_address;

    //! Do we use the pass address?
    bool            use_sim_pass_address = false;

    //! Do we use the fail address?
    bool            use_sim_fail_address = false;
    
    //! Construct all of the objects we need inside the testbench.
    void build();
    
    //! Called immediately before the run function.
    void pre_run();
    
    //! The main phase of the DUT simulation.
    void run();

    //! Called after the run function has returned.
    void post_run();

    //! Where to dump waveforms.
    std::string waves_file;
    
    //! Whether or not to dump waveforms.
    bool        waves_dump;

    //! Drain the DUT trace queue from the DUT wrapper and process as needed.
    void        drain_dut_trace();

};

#endif

