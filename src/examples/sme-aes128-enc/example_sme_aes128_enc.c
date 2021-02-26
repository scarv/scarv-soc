
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

uint32_t ck   [AES_STATE_WORDS] = {
    0x01234567,0x89abcdef,0x01234567,0x89abcdef
} ; //!< Cipher key

uint32_t f_pt [AES_STATE_WORDS]; //!< Fixed Plaintext
uint32_t r_pt [AES_STATE_WORDS]; //!< Random Plaintext
uint32_t ct   [AES_STATE_WORDS]; //!< Ciphertext 

// The expanded cipher key.
uint32_t exp_ck [SME_SMAX][AES128_RK_WORDS];

scass_target_var scass_vars [] = {
    {"ck", sizeof(  ck),   ck,   ck, SCASS_FLAG_INPUT       },  
    {"pt", sizeof(f_pt), r_pt, f_pt, SCASS_FLAGS_TTEST_IN   },  
    {"ct", sizeof(  ct),   ct,   ct, SCASS_FLAG_OUTPUT      }  
};

/*!
@brief Do any one-time setup needed for the experiment.
@param cfg - The scass_target_cfg object associated with the experiment.
@returns 0 on success, non-zero on failure.
*/
uint8_t scass_experiment_init(
    scass_target_cfg * cfg
){
    for(int s = 0; s < SME_SMAX; s ++) {
        for(int i = 0; i < AES128_RK_WORDS ; i ++) {
            exp_ck[s][i] = 0;
        }
    }

    for(int s = 0; s < AES_STATE_WORDS; s ++) {
        ct[s] = 0;
    }
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
    uint32_t * p_pt = fixed ? f_pt : r_pt;

    sme_aes128_enc_key_exp(exp_ck, ck);

    scarvsoc_gpio_set_outputs(SCARVSOC_GPIO1, 1);

    sme_aes128_enc_block(ct, p_pt, exp_ck);

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

    scass_cfg.experiment_name   = "sme-aes128-enc";
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
