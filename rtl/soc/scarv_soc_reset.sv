
//
// module: scarv_soc_reset
//
//  Reset handler block for the SCARV SoC and peripherals.
//
module scarv_soc_reset #(
EXT_RESET_ACTIVE_HIGH = 1, // Is the external reset signal active high?
RESET_CYCLES_BASE   = 16, // Hold system in reset for N cycles.
RESET_CYCLES_CCX    = 16, // Hold CCX in reset for N cycles
RESET_CYCLES_PERIPH = 16  // Hold peripherals in reset for N cycles.
)(
input  wire f_clk           , // Free running clock.
input  wire f_clk_locked    , // Free running clock PLL locked.
input  wire sys_reset       , // System reset. See EXT_RESET_ACTIVE_HIGH

output reg  resetn_ccx      , // Core complex active low, synchronous reset
output reg  resetn_periph     // Peripherals  active low, synchronous reset
);

localparam RESET_CYCLES_TOTAL =
    RESET_CYCLES_CCX        +
    RESET_CYCLES_PERIPH     +
    RESET_CYCLES_BASE       ;

localparam RC = $clog2(RESET_CYCLES_TOTAL)-1;

localparam COUNT_PERIPH = RESET_CYCLES_BASE + RESET_CYCLES_PERIPH;
localparam COUNT_CCX    = COUNT_PERIPH      + RESET_CYCLES_CCX   ;

reg     rst_samp_0;
reg     rst_samp;

always @(posedge f_clk) begin
    rst_samp_0 <= sys_reset;
    rst_samp <= rst_samp_0;
end

reg     [RC:0]   counter;
wire    [RC:0] n_counter = counter + 1;

always @(posedge f_clk) begin
    if( EXT_RESET_ACTIVE_HIGH &&  rst_samp||
       !EXT_RESET_ACTIVE_HIGH && !rst_samp) begin
        counter <= 'b0;
    end else if(f_clk_locked && n_counter != 0) begin
        counter <= n_counter;
    end
end

always @(posedge f_clk) begin
    resetn_ccx      <= counter >= COUNT_CCX     ;
    resetn_periph   <= counter >= COUNT_PERIPH  ;
end


endmodule
