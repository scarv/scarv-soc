
// $REPO_HOME/src/bsp/include
#include "scarvsoc.h"

// $REPO_HOME/extern/fw-acquisition/target/scass
#include "scass_target.h"

// $REPO_HOME/extern/scarv-cpu/src/sme
#include "scarv_cpu_sme.h"
#include "sme_chacha20.h"

#ifndef SME_SMAX
#define SME_SMAX 3
#endif

scass_target_clk_info scass_clk_info = {
    .sys_clk_rate = 50000000,
    .sys_clk_src  = SCASS_CLK_SRC_INTERNAL
};

uint32_t f_blk_i [16];
uint32_t r_blk_i [16];
uint32_t   blk_o [16];

uint32_t blk_i_masked[SME_SMAX][16];
uint32_t blk_o_masked[SME_SMAX][16];

scass_target_var scass_vars [] = {
    {"blk_i", sizeof(f_blk_i), r_blk_i, f_blk_i, SCASS_FLAGS_TTEST_IN   },  
    {"blk_o", sizeof(  blk_o),   blk_o,   blk_o, SCASS_FLAG_OUTPUT     },  
};

/*!
@brief Do any one-time setup needed for the experiment.
@param cfg - The scass_target_cfg object associated with the experiment.
@returns 0 on success, non-zero on failure.
*/
uint8_t scass_experiment_init(
    scass_target_cfg * cfg
){
    return 0;
}
    
/*!
@brief Run the experiment once.
@details May be set to NULL, in which case it is never called.
@param cfg - The scass_target_cfg object associated with the experiment.
@param fixed - Use fixed variants of each variable
@returns 0 on success, non-zero on failure.
*/
uint8_t scass_experiment_run(
    scass_target_cfg * cfg,
    char               fixed
){
    uint32_t * blk_i = fixed ? f_blk_i : r_blk_i;

    sme_chacha20_mask(blk_i_masked, blk_i);
    
    uint32_t cycles_begin, cycles_end;
    uint32_t instrs_begin, instrs_end;

    asm volatile (
        "rdcycle %0; rdinstret %1" : "=r"(cycles_begin), "=r"(instrs_begin) :
    );

    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO1, 1);

    sme_chacha20_block(blk_o_masked, blk_i_masked);

    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO1, 0);
    
    asm volatile (
        "rdcycle %0; rdinstret %1" : "=r"(cycles_end  ), "=r"(instrs_end  ) :
    );

    sme_chacha20_unmask(blk_o, blk_o_masked);

    cfg -> experiment_cycles    = cycles_end - cycles_begin;
    cfg -> experiment_instrret  = instrs_end - instrs_begin;

    return 0;
}

uint8_t uart_rd_char(void) {
    return scarvsoc_uart_getc_b(SCARVSOC_UART0);
}

void    uart_wr_char(uint8_t c) {
    scarvsoc_uart_putc_b(SCARVSOC_UART0, (char)c);
}

/*!
@brief A simple test program which echoes recieved UART bytes.
*/
int main(int argc, char ** argv) {

    scass_target_cfg scass_cfg;

    scass_cfg.experiment_name   = "sme-chacha20-enc";
    scass_cfg.variables         = scass_vars;
    scass_cfg.num_variables     = sizeof(scass_vars)/sizeof(scass_target_var);
    scass_cfg.randomness        = NULL;
    scass_cfg.randomness_len    = 0;

    scass_cfg.clk_cfgs          = &scass_clk_info;
    scass_cfg.current_clk_cfg   = 0;
    scass_cfg.num_clk_cfgs      = 1;

    scass_cfg.scass_io_rd_char  = uart_rd_char;
    scass_cfg.scass_io_wr_char  = uart_wr_char;

    scass_cfg.scass_experiment_init = scass_experiment_init;
    scass_cfg.scass_experiment_run  = scass_experiment_run;

    scass_loop(&scass_cfg);
}
