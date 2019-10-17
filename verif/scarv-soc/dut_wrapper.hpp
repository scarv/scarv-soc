
#ifndef DUT_WRAPPER_HPP
#define DUT_WRAPPER_HPP

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "Vscarv_soc.h"

class dut_wrapper {

public:

    //! Path to dump wave files too
    bool         dump_waves        = false;
    
    //! File path waves are dumped too.
    std::string  vcd_wavefile_path = "waves.vcd";

    /*!
    @brief Create a new dut_wrapper object
    @param in dump_waves - If true, write wave file.
    @oaram in wavefile path to dump waves too.
    */
    dut_wrapper (
        bool            dump_waves  ,
        std::string     wavefile
    );

    
    //! Put the dut in reset.
    void dut_set_reset();
    
    //! Take the DUT out of reset.
    void dut_clear_reset();

    //! Simulate the DUT for a single clock cycle
    void dut_step_clk();
    
    //! Return the number of simulation ticks so far.
    uint64_t get_sim_time() {
        return this -> sim_time;
    }
    
    //! Handle to the VCD file for dumping waveforms.
    VerilatedVcdC* trace_fh;

protected:

    //! Number of model evaluations per clock cycle
    const uint32_t  evals_per_clock = 10;
    
    //! Simulation time, incremented with each tick.
    uint64_t sim_time;
    
    //! The DUT object being wrapped.
    Vscarv_soc * dut;

    //! Called on every rising edge of the main clock.
    void posedge_gclk();

};

#endif

