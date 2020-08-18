
module uart_fifo #(
parameter DEPTH = 8, // Number of elements in the FIFO
parameter WIDTH = 8  // Width of the elements in the FIFO.
)(
input  wire             g_clk      , // Clock
output wire             g_clk_req  , // Clock request
input  wire             g_resetn   , // Reset
           
output wire             full       , // Cannot accept any more inputs.
input  wire             push       , // Input word valid.
input  wire[WIDTH-1: 0] in_data    , // Input word data.
           
output wire             out_valid  , // Output word valid.
output wire[WIDTH-1: 0] out_data   , // Output data word.
input  wire             pop          // Extract an output word.
);

localparam DW = WIDTH-1;
localparam D  = DEPTH-1;

reg [DW:0] elems [D:0];
reg        valid [D:0];

wire [D:0] moving;

assign     g_clk_req = |moving;

assign     out_data  = elems[D];
assign     out_valid = valid[D];
assign     full      = valid[0];

genvar i;
generate for(i = 0; i < DEPTH; i=i+1) begin : gen_elements

wire prev_valid     = i == 0 ?  push : valid[i-1];
wire cur_valid      =                  valid[i  ];
wire next_valid     = i == DW? !pop  : valid[i+1];

wire prog_in        = prev_valid && !cur_valid ;
wire prog_out       = cur_valid  && !next_valid;

assign moving[i]    = prog_in || prog_out;

wire [DW:0] n_data  = i == 0 ? in_data : elems[i-1];
wire        n_valid = prog_out ? prog_in :
                       valid[i]? 1'b1    :
                                 prog_in ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        elems[i] <= {WIDTH{1'b0}};
    end else if(prog_in) begin
        elems[i] <= n_data;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        valid[i] <= 1'b0;
    end else begin
        valid[i] <= n_valid;
    end
end

end endgenerate

endmodule
