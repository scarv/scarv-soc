
//
// module: scarv_rng_top
//
//  Top level of the SCARV random number generator.
//
module scarv_rng_top (

input               g_clk           , // global clock
input               g_resetn        , // synchronous reset

input  wire         rng_req_valid   , // Signal a new request to the RNG
input  wire [ 2:0]  rng_req_op      , // Operation to perform on the RNG
input  wire [31:0]  rng_req_data    , // Suplementary seed/init data
output wire         rng_req_ready   , // RNG accepts request

output wire         rng_rsp_valid   , // RNG response data valid
output wire [ 2:0]  rng_rsp_status  , // RNG status
output wire [31:0]  rng_rsp_data    , // RNG response / sample data.
input  wire         rng_rsp_ready     // CPU accepts response.

);

/*
Which instance of the RNG should we use?
Valid values are one of the following strings:
- "lfsr" - A simple 32-bit linear feedback shift register.
*/
parameter RNG_TYPE = "lfsr";


generate if(RNG_TYPE == "lfsr") begin   // LFSR

//
// Simple LFSR instance
scarv_rng_lfsr i_scarv_rng_lfsr(
.g_clk          (g_clk          ), // global clock
.g_resetn       (g_resetn       ), // synchronous reset
.rng_req_valid  (rng_req_valid  ), // Signal a new request to the RNG
.rng_req_op     (rng_req_op     ), // Operation to perform on the RNG
.rng_req_data   (rng_req_data   ), // Suplementary seed/init data
.rng_req_ready  (rng_req_ready  ), // RNG accepts request
.rng_rsp_valid  (rng_rsp_valid  ), // RNG response data valid
.rng_rsp_status (rng_rsp_status ), // RNG status
.rng_rsp_data   (rng_rsp_data   ), // RNG response / sample data.
.rng_rsp_ready  (rng_rsp_ready  )  // CPU accepts response.
);

end else begin

    // Invalid RNG instance.

end endgenerate

endmodule
