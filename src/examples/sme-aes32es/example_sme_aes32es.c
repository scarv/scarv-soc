
// $REPO_HOME/src/bsp/include
#include "scarvsoc.h"

// $REPO_HOME/extern/fw-acquisition/target/scass
#include "scass_target.h"

// $REPO_HOME/extern/scarv-cpu/src/sme
#include "scarv_cpu_sme.h"
#include "sme_aes.h"

#ifndef SME_SMAX
#define SME_SMAX 3
#endif

scass_target_clk_info scass_clk_info = {
    .sys_clk_rate = 50000000,
    .sys_clk_src  = SCASS_CLK_SRC_INTERNAL
};

uint32_t f_rs1, r_rs1; //!< source reg 1
uint32_t f_rs2, r_rs2; //!< source reg 2

// The expanded cipher key.
uint32_t exp_ck [SME_SMAX][AES128_RK_WORDS];

scass_target_var scass_vars [] = {
    {"rs1", sizeof(f_rs1),&f_rs1,&r_rs1, SCASS_FLAGS_TTEST_IN   },  
    {"rs2", sizeof(f_rs2),&f_rs2,&r_rs2, SCASS_FLAGS_TTEST_IN   }
};

// Target function containing code to test for leakage.
extern void experiment_payload(uint32_t rs1, uint32_t rs2);

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
    uint32_t rs1 = fixed ? f_rs1 : r_rs1;
    uint32_t rs2 = fixed ? f_rs2 : r_rs2;

    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO1, 1);

    experiment_payload(rs1, rs2);

    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO1, 0);

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

    scass_cfg.experiment_name   = "sme-aes32es";
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
