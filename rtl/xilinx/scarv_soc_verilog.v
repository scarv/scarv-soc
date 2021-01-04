
//
// module: scarv_soc_verilog
//
//  Verilog wrapper module for the actual "scarv_soc" top level module
//  written in SystemVerilog.
//
//  This gets round a *stupid* vivado problem, where you can't have
//  SystemVerilog modules instanced directly in a Block Design.
//
module scarv_soc_verilog #(
//! Reset value for the mtimecmp memory mapped register.
parameter CCX_CPU_MTIMECMP_RESET = 64'hFFFF_FFFF_FFFF_FFFF,

//! Reset value for the program counter.
parameter CCX_CPU_PC_RESET   = 32'b0,

//! Memory initialisation file for the ROM.
parameter [255*8-1:0] CCX_ROM_INIT_FILE = "rom.hex",
parameter [255*8-1:0] CCX_RAM_INIT_FILE = "ram.hex",

parameter   UART_BIT_RATE  =    115200, // bits / sec
parameter   UART_CLK_HZ    = 50_000_000,
parameter   UART_STOP_BITS = 1         ,

//! Is the sys_reset signal active high?
parameter EXT_RESET_ACTIVE_HIGH = 1,

//! Number of GPIO pins.
parameter  PERIPH_GPIO_NUM = 16 
)(

input  wire             f_clk           , // Free running clock.
input  wire             f_clk_locked    , // Free running clock PLL locked?
input  wire             sys_reset       , // Global Active low sync reset.

input  wire             uart_rxd        , // UART Recieve
output wire             uart_txd        , // UART Transmit

output wire [PERIPH_GPIO_NUM-1:0]   gpio  // GPIO wires

);

//
// Testbench code for Verilator
// ------------------------------------------------------------

`ifdef SCARV_SOC_VERILATOR
    assign trs_valid = cpu_trs_valid;
    assign trs_instr = cpu_trs_instr;
    assign trs_pc    = cpu_trs_pc   ;
`endif

//
// Actual SCARV SoC Instance
// ------------------------------------------------------------

scarv_soc #(
.CCX_CPU_MTIMECMP_RESET  (CCX_CPU_MTIMECMP_RESET  ),
.CCX_CPU_PC_RESET        (CCX_CPU_PC_RESET        ),
.CCX_ROM_INIT_FILE       (CCX_ROM_INIT_FILE       ),
.CCX_RAM_INIT_FILE       (CCX_RAM_INIT_FILE       ),
.EXT_RESET_ACTIVE_HIGH   (EXT_RESET_ACTIVE_HIGH   ),
.UART_BIT_RATE           (UART_BIT_RATE           ),
.UART_CLK_HZ             (UART_CLK_HZ             ),
.UART_STOP_BITS          (UART_STOP_BITS          ),
.PERIPH_GPIO_NUM         (PERIPH_GPIO_NUM         )
) i_scarv_soc (
.f_clk   (f_clk   ), // Free running clock.
.f_clk_locked(f_clk_locked),
.sys_reset(sys_reset), // Global Active low sync reset.
.uart_rxd(uart_rxd), // UART Recieve
.uart_txd(uart_txd), // UART Transmit
.gpio    (gpio    )  // GPIO wires.
);

endmodule
