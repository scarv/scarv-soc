
//
// module: uart_top
//
//  Top level of the UART peripheral
//
module uart_top ( 

input  wire             g_clk           , // Gated clock
output wire             g_clk_req       , // Clock request
input  wire             g_resetn        , // Global Active low sync reset.

input  wire             uart_rx         , // UART Recieve
output wire             uart_tx         , // UART Transmit

scarv_ccx_memif.RSP     memif             // Memory request interface.

);

//
// Stub out for now
assign uart_tx      = 1'b1;
assign memif.gnt    = 1'b1;
assign memif.error  = 1'b0;


endmodule


