
//
// module: ic_cpu_bus_bram_bridge
//
//  Bridge to transform the two request/response channels of the
//  CPU core into a simple BRAM interface.
//
module ic_cpu_bus_bram_bridge (
input        g_clk                  ,
input        g_resetn               ,

output wire         bram_cen        ,
output wire  [31:0] bram_addr       ,
output wire  [31:0] bram_wdata      ,
output wire  [ 3:0] bram_wstrb      ,
input  wire         bram_stall      ,
input  wire  [31:0] bram_rdata      ,

input  wire         enable          , // Enable requests / does addr map?

input  wire         mem_req         , // Start memory request
output wire         mem_gnt         , // request accepted
input  wire         mem_wen         , // Write enable
input  wire [3:0]   mem_strb        , // Write strobe
input  wire [31:0]  mem_wdata       , // Write data
input  wire [31:0]  mem_addr        , // Read/Write address

output reg          mem_recv        , // Instruction memory recieve response.
input  wire         mem_ack         , // Instruction memory ack response.
output wire         mem_error       , // Error
output wire [31:0]  mem_rdata         // Read data
);

assign mem_rdata    = buffer_req ? buffer_rdata : bram_rdata;

assign mem_error    = 1'b0;
assign mem_gnt      = !bram_stall && !buffer_req;
assign mem_error    = 1'b0;

assign bram_addr    = buffer_req ? buffer_addr  : mem_addr ;
assign bram_wdata   = buffer_req ? buffer_wdata : mem_wdata;
assign bram_wstrb   = !mem_wen   ? 4'b0000      :
                      buffer_req ? buffer_wstrb :
                                   mem_strb     ;
assign bram_cen     = (mem_req && mem_gnt && enable);

wire   mem_stalled  = mem_recv && !mem_ack;
wire   bram_ready   = bram_cen && !bram_stall;

wire   n_mem_recv   = (mem_stalled                           ) || 
                      (bram_ready                            ) ||
                      (buffer_req && !(mem_recv && mem_ack)  );

reg    buffer_req   ;
wire   n_buffer_req = 
    buffer_req ? mem_recv&& !mem_ack                        :
                 mem_req && mem_gnt && mem_recv && !mem_ack ;

reg  [31:0] buffer_addr ;
reg  [31:0] buffer_wdata;
reg  [31:0] buffer_rdata;
reg  [ 3:0] buffer_wstrb;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        mem_recv    <= 1'b0;
        buffer_req  <= 1'b0;
    end else begin
        mem_recv    <= n_mem_recv   ;
        buffer_req  <= n_buffer_req ;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        buffer_addr  <= 32'b0;
        buffer_wdata <= 32'b0;
        buffer_rdata <= 32'b0;
        buffer_wstrb <=  4'b0;
    end else if(n_buffer_req) begin
        buffer_addr  <= bram_addr ;
        buffer_wdata <= bram_wdata;
        buffer_rdata <= bram_rdata;
        buffer_wstrb <= mem_wen ? bram_wstrb : 4'b0000;
    end
end

endmodule
