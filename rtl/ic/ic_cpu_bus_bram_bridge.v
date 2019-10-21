
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

output wire         mem_recv        , // Instruction memory recieve response.
input  wire         mem_ack         , // Instruction memory ack response.
output wire         mem_error       , // Error
output wire [31:0]  mem_rdata         // Read data
);

assign mem_error    = 1'b0;
assign mem_gnt      = !bram_stall && !fsm_wait && !fsm_buf;
assign mem_error    = 1'b0;

assign mem_rdata    = fsm_wait   ? buffer_rdata : bram_rdata;
assign bram_addr    = fsm_buf    ? buffer_addr  : mem_addr ;
assign bram_wdata   = fsm_buf    ? buffer_wdata : mem_wdata;
assign bram_wstrb   = !mem_wen   ? 4'b0000      :
                      fsm_buf    ? buffer_wstrb :
                                   mem_strb     ;
assign bram_cen     = (mem_req && mem_gnt && enable);

wire   mem_stalled  = mem_recv && !mem_ack;
wire   bram_ready   = bram_cen && !bram_stall;

assign mem_recv     = fsm_rsp || fsm_buf || fsm_wait;

wire   fsm_rsp      = fsm == FSM_RSP ;
wire   fsm_buf      = fsm == FSM_BUF ;
wire   fsm_wait     = fsm == FSM_WAIT;

localparam FSM_IDLE = 2'b00;
localparam FSM_RSP  = 2'b01;
localparam FSM_WAIT = 2'b10;
localparam FSM_BUF  = 2'b11;

reg  [ 1:0]   fsm       ;
reg  [ 1:0] n_fsm       ;

always @(*) begin
    if(fsm == FSM_IDLE) begin
        if(mem_req && mem_gnt) begin
            n_fsm = FSM_RSP;
        end else begin
            n_fsm = FSM_IDLE;
        end
    end else if(fsm == FSM_RSP) begin
        if(mem_recv && !mem_ack && mem_req && mem_gnt) begin
            n_fsm = FSM_WAIT;
        end else if(mem_req && mem_gnt && mem_recv && mem_ack) begin
            n_fsm = FSM_RSP;
        end else if(!mem_req && mem_recv && !mem_ack) begin
            n_fsm = FSM_RSP;
        end else begin
            n_fsm = FSM_IDLE;
        end
    end else if(fsm == FSM_WAIT) begin
        if(mem_recv && mem_ack) begin
            n_fsm = FSM_BUF;
        end else begin
            n_fsm = FSM_WAIT;
        end
    end else if(fsm == FSM_BUF) begin
        if(mem_recv && mem_ack) begin
            n_fsm = FSM_IDLE;
        end else begin
            n_fsm = FSM_BUF;
        end
    end else begin
        n_fsm = FSM_IDLE;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        fsm <= FSM_IDLE;
    end else begin
        fsm <= n_fsm;
    end
end

reg  [31:0] buffer_addr ;
reg  [31:0] buffer_wdata;
reg  [31:0] buffer_rdata;
reg  [ 3:0] buffer_wstrb;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        buffer_addr  <= 32'b0;
        buffer_wdata <= 32'b0;
        buffer_rdata <= 32'b0;
        buffer_wstrb <=  4'b0;
    end else if(n_fsm == FSM_WAIT && !fsm_wait) begin
        buffer_addr  <= bram_addr ;
        buffer_wdata <= bram_wdata;
        buffer_rdata <= bram_rdata;
        buffer_wstrb <= mem_wen ? bram_wstrb : 4'b0000;
    end
end

endmodule
