
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
        this -> pre_run();   
        this -> run();   
        this -> post_run();
    }

    uint64_t        max_sim_time     =  10000;

    //! Return total simulation time so far.
    uint64_t get_sim_time() {
        return this -> dut -> get_sim_time();
    }

    bool            sim_finished    = false;

    bool            sim_passed      = false;

protected:
    
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
    
};

#endif

