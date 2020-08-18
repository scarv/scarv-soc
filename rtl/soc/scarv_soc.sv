
//
// module: scarv_soc
//
//  Top level of the SCARV SoC core module.
//
module scarv_soc (

input  wire             f_clk           , // Free running clock.
input  wire             g_resetn        , // Global Active low sync reset.

input  wire             uart_rx         , // UART Recieve
output wire             uart_tx         , // UART Transmit

output wire [GPION:0]   gpio_io         , // GPIO wire direction. 1=in, 0=out.
output wire [GPION:0]   gpio_out        , // GPIO outputs.
input  wire [GPION:0]   gpio_in           // GPIO inputs.

`ifdef SCARV_SOC_VERILATOR              ,
output wire             trs_valid       , // CPU trace word valid
output wire [31:0]      trs_pc          , // CPU trace program counter
output wire [31:0]      trs_instr         // CPU traced instruction.
`endif

);

//
// SCARV CPU Core Complex Parameters
// ------------------------------------------------------------

parameter CCX_MEM_ROM_BASE     = 32'h0000_0000; //! Base address of ROM
parameter CCX_MEM_ROM_SIZE     = 32'h0000_0400; //! Size in bytes of ROM.
parameter CCX_MEM_RAM_BASE     = 32'h0001_0000; //! Base address of RAM
parameter CCX_MEM_RAM_SIZE     = 32'h0001_0000; //! Size in bytes of RAM.
parameter CCX_MEM_MMIO_BASE    = 32'h0002_0000; //! Base address of MMIO.
parameter CCX_MEM_MMIO_SIZE    = 32'h0000_0100; //! Size in bytes of MMIO
parameter CCX_MEM_EXT_BASE     = 32'h1000_0000; //! Base address of EXT Mem.
parameter CCX_MEM_EXT_SIZE     = 32'h1000_0000; //! Size in bytes of EXT Mem.

//! Base addr of UART.
parameter PERIPH_MEM_UART_BASE = CCX_MEM_EXT_BASE | 32'h0000_0000;

//! Base addr of GPIO.
parameter PERIPH_MEM_GPIO_BASE = CCX_MEM_EXT_BASE | 32'h0000_1000;

//! Reset value for the mtimecmp memory mapped register.
parameter CCX_CPU_MTIMECMP_RESET = 64'hFFFF_FFFF_FFFF_FFFF;

//! Reset value for the program counter.
parameter CCX_CPU_PC_RESET   = 32'b0;

/* verilator lint_off WIDTH */
//! Memory initialisation file for the ROM.
parameter [255*8-1:0] CCX_ROM_INIT_FILE = "rom.hex";
parameter [255*8-1:0] CCX_RAM_INIT_FILE = "ram.hex";
/* verilator lint_on WIDTH */

//
// Testbench code for Verilator
// ------------------------------------------------------------

`ifdef SCARV_SOC_VERILATOR
    assign trs_valid = cpu_trs_valid;
    assign trs_instr = cpu_trs_instr;
    assign trs_pc    = cpu_trs_pc   ;
`endif

//
// Peripheral Sub-system Parameters
// ------------------------------------------------------------

//! Number of GPIO pins.
parameter  PERIPH_GPIO_NUM = 16;
localparam GPION           = PERIPH_GPIO_NUM - 1;


//
// Inter sub-system wiring.
// ------------------------------------------------------------

wire        cpu_int_ext         ; // CPU External interrupt.
wire [31:0] cpu_int_ext_cause   ; // CPU External interrupt cause.

wire [31:0] cpu_trs_pc          ; // CPU Trace program counter.
wire [31:0] cpu_trs_instr       ; // CPU Trace instruction.
wire        cpu_trs_valid       ; // CPU Trace output valid.

scarv_ccx_memif #() ccx_memif() ; // Core complex memory interface

//
// Clock request and gating.
// ------------------------------------------------------------

wire        g_clk_uart          ; // UART Clock
wire        g_clk_gpio          ; // GPIO Clock

wire        g_clk_req_uart      ; // UART Clock request
wire        g_clk_req_gpio      ; // GPIO Clock request

//
// Core Complex Subsystem instance
// ------------------------------------------------------------

//
// instance: scarv_ccx_top
//
//  Top level module of the core complex.
//
scarv_ccx_top #(
.ROM_BASE       (CCX_MEM_ROM_BASE       ),
.ROM_SIZE       (CCX_MEM_ROM_SIZE       ),
.RAM_BASE       (CCX_MEM_RAM_BASE       ),
.RAM_SIZE       (CCX_MEM_RAM_SIZE       ),
.MMIO_BASE      (CCX_MEM_MMIO_BASE      ),
.MMIO_SIZE      (CCX_MEM_MMIO_SIZE      ),
.EXT_BASE       (CCX_MEM_EXT_BASE       ),
.EXT_SIZE       (CCX_MEM_EXT_SIZE       ),
.MTIMECMP_RESET (CCX_CPU_MTIMECMP_RESET ),
.PC_RESET       (CCX_CPU_PC_RESET       ),
.ROM_INIT_FILE  (CCX_ROM_INIT_FILE      ),
.RAM_INIT_FILE  (CCX_RAM_INIT_FILE      )
) i_scarv_ccx_top (
.f_clk              (f_clk              ), // Free-running clock.
.g_resetn           (g_resetn           ), // Synchronous active low reset.
.int_ext            (cpu_int_ext        ), // External interrupt.
.int_ext_cause      (cpu_int_ext_cause  ), // External interrupt cause.
.cpu_trs_pc         (cpu_trs_pc         ), // Trace program counter.
.cpu_trs_instr      (cpu_trs_instr      ), // Trace instruction.
.cpu_trs_valid      (cpu_trs_valid      ), // Trace output valid.
.if_ext             (ccx_memif          )  // External memory requests.
);


//
// Core Complex Subsystem instance
// ------------------------------------------------------------
scarv_soc_periph_top #(
.BASE_UART       (PERIPH_MEM_UART_BASE  ),
.BASE_GPIO       (PERIPH_MEM_GPIO_BASE  ),
.PERIPH_GPIO_NUM (PERIPH_GPIO_NUM       )
) i_scarv_soc_periph_top (
.f_clk              (f_clk              ), // Free running clock.
.g_clk_uart         (g_clk_uart         ), // UART Clock
.g_clk_gpio         (g_clk_gpio         ), // GPIO Clock
.g_clk_req_uart     (g_clk_req_uart     ), // UART Clock request
.g_clk_req_gpio     (g_clk_req_gpio     ), // GPIO Clock request
.g_resetn           (g_resetn           ), // Global Active low sync reset.
.uart_rx            (uart_rx            ), // UART Recieve
.uart_tx            (uart_tx            ), // UART Transmit
.gpio_io            (gpio_io            ), // GPIO wire direction.
.gpio_out           (gpio_out           ), // GPIO outputs.
.gpio_in            (gpio_in            ), // GPIO inputs.
.memif              (ccx_memif          )  // Memory requests.
);

endmodule
