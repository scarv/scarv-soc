
#ifndef DUT_WRAPPER_HPP
#define DUT_WRAPPER_HPP

#include <queue>
#include <iostream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "svdpi.h"

#include "axi4lite/a4l_txns.hpp"
#include "axi4lite/a4l_slave_agent.hpp"

#include "Vscarv_soc.h"
#include "Vscarv_soc_scarv_soc.h"
#include "Vscarv_soc__Dpi.h"

//! A trace packet emitted by the core post-writeback.
typedef struct dut_trace_pkt {
    uint32_t program_counter;
    uint32_t instr_word;
} dut_trace_pkt_t;

//! Class that wraps the verilated DUT and is used to interface with it.
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
    
    //! Trace of post-writeback PC and instructions.
    std::queue<dut_trace_pkt_t> dut_trace;


protected:
    
    //! Load a binary file into the RAM or ROM memories.
    void load_bin_file_to_memory (std::string file_path);

    //! Number of model evaluations per clock cycle
    const uint32_t  evals_per_clock = 10;
    
    //! Simulation time, incremented with each tick.
    uint64_t sim_time;
    
    //! The DUT object being wrapped.
    Vscarv_soc * dut;

    //! AXI4Lite slave interface agent.
    a4l_slave_agent * axi_agent;

    //! Called on every rising edge of the main clock.
    void posedge_gclk();

};

#endif

