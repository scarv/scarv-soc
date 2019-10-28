
//
// module: ic_error_rsp_stub
//
//  A stub peripheral module which responds only with bus errors.
//
module ic_error_rsp_stub (
input        g_clk                  ,
input        g_resetn               ,

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

assign mem_gnt      = !fsm_wait && !fsm_buf;
assign mem_error    = 1'b1;

assign mem_rdata    = 32'b0;

wire   mem_stalled  = mem_recv && !mem_ack;

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

endmodule
