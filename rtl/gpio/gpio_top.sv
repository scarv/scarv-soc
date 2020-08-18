
//
// module: gpio_top
//
//  Top level of the GPIO peripheral
//
module gpio_top ( 

input  wire             g_clk           , // Gated clock
output wire             g_clk_req       , // Clock request
input  wire             g_resetn        , // Global Active low sync reset.

output wire [GPION:0]   gpio_io         , // GPIO wire direction. 1=in, 0=out.
output wire [GPION:0]   gpio_out        , // GPIO outputs.
input  wire [GPION:0]   gpio_in         , // GPIO inputs.

scarv_ccx_memif.RSP     memif             // Memory request interface.

);

//! Number of GPIO pins.
parameter  PERIPH_GPIO_NUM = 16;
localparam GPION           = PERIPH_GPIO_NUM - 1;

//
// Stub out for now
assign gpio_io      = {PERIPH_GPIO_NUM{1'b0}};
assign gpio_out     = {PERIPH_GPIO_NUM{1'b0}};

assign memif.gnt    = 1'b1;
assign memif.error  = 1'b0;

endmodule


