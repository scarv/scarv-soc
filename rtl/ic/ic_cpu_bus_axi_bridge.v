
//
// module: ic_cpu_bus_axi_bridge
//
//  Bridge to transform the two request/response channels of the
//  CPU core into the 5 AXI4-Lite bus channels.
//
module ic_cpu_bus_axi_bridge (

input  wire         m0_aclk         , // AXI Clock
input  wire         m0_aresetn      , // AXI Reset

output wire         m0_awvalid      , //
input  wire         m0_awready      , //
output wire [31:0]  m0_awaddr       , //
output wire [ 2:0]  m0_awprot       , //

output wire         m0_wvalid       , //
input  wire         m0_wready       , //
output wire [31:0]  m0_wdata        , //
output wire [ 3:0]  m0_wstrb        , //

input  wire         m0_bvalid       , //
output wire         m0_bready       , //
input  wire [ 1:0]  m0_bresp        , //

output wire         m0_arvalid      , //
input  wire         m0_arready      , //
output wire [31:0]  m0_araddr       , //
output wire [ 2:0]  m0_arprot       , //

input  wire         m0_rvalid       , //
output wire         m0_rready       , //
input  wire [ 1:0]  m0_rresp        , //
input  wire [31:0]  m0_rdata        , //

input  wire         enable          , // Enable requests / does addr map?

input  wire         mem_req         , // Start memory request
output wire         mem_gnt         , // request accepted
input  wire         mem_wen         , // Write enable
input  wire [ 3:0]  mem_strb        , // Write strobe
input  wire [31:0]  mem_wdata       , // Write data
input  wire [31:0]  mem_addr        , // Read/Write address

output wire         mem_recv        , // Instruction memory recieve response.
input  wire         mem_ack         , // Instruction memory ack response.
output wire         mem_error       , // Error
output wire [31:0]  mem_rdata         // Read data
);

//
// Constant assignments
// ------------------------------------------------------------

assign m0_awaddr = buf_addr ;
assign m0_awprot = 3'b000   ; // Unprivilidged, non-secure, Data

assign m0_wdata  = buf_wdata;
assign m0_wstrb  = buf_strb ;

assign m0_araddr = buf_addr ;
assign m0_arprot = 3'b000   ; // Unprivilidged, non-secure, Data

assign mem_rdata = m0_rdata ;

assign mem_error =
    fsm_rd_rsp_wait && |m0_rresp ||
    fsm_wr_rsp_wait && |m0_bresp  ;

reg [ 3:0]  buf_strb        ; // Buffered Write strobe
reg [31:0]  buf_wdata       ; // Buffered Write data
reg [31:0]  buf_addr        ; // Buffered Read/Write address

always @(posedge m0_aclk) begin
    if(!m0_aresetn) begin
        buf_strb  <=  4'b0;
        buf_wdata <= 32'b0;
        buf_addr  <= 32'b0;
    end else if(cpu_req) begin
        buf_strb  <= mem_strb ;
        buf_wdata <= mem_wdata;
        buf_addr  <= mem_addr ;
    end
end

//
// Bus transaction events
// ------------------------------------------------------------

wire    cpu_req = mem_req  && mem_gnt;
wire    cpu_rsp = mem_recv && mem_ack;

wire    axi_rd_req = m0_arvalid && m0_arready;
wire    axi_aw_req = m0_awvalid && m0_awready;
wire    axi_wd_req = m0_wvalid  && m0_wready ;
wire    axi_rd_rsp = m0_rvalid  && m0_rready ;
wire    axi_wr_rsp = m0_bvalid  && m0_bready ;

//
// CPU Bus req/gnt assignments.
// ------------------------------------------------------------

assign mem_gnt  = fsm_idle;

assign mem_recv = fsm_rd_rsp_wait && m0_rvalid ||
                  fsm_wr_rsp_wait && m0_bvalid ;

//
// AXI Bus valid/ready assignments.
// ------------------------------------------------------------

assign m0_arvalid = fsm_rd_req_wait                         ;

assign m0_awvalid = fsm_wr_req_wait                        ||
                    fsm_wa_req_wait                         ;

assign m0_wvalid  = fsm_wr_req_wait                        ||
                    fsm_wd_req_wait                         ;

assign m0_rready  = fsm_rd_rsp_wait && mem_ack              ;

assign m0_bready  = fsm_wr_rsp_wait && mem_ack              ;

//
// FSM State handling
// ------------------------------------------------------------

localparam FSM_IDLE         = 3'd0;
localparam FSM_RD_REQ_WAIT  = 3'd1;
localparam FSM_WR_REQ_WAIT  = 3'd2;
localparam FSM_WA_REQ_WAIT  = 3'd3;
localparam FSM_WD_REQ_WAIT  = 3'd4;
localparam FSM_RD_RSP_WAIT  = 3'd5;
localparam FSM_WR_RSP_WAIT  = 3'd6;

reg [2:0]   fsm;
reg [2:0] n_fsm;

wire fsm_idle        = fsm == FSM_IDLE       ;
wire fsm_rd_req_wait = fsm == FSM_RD_REQ_WAIT;
wire fsm_wr_req_wait = fsm == FSM_WR_REQ_WAIT;
wire fsm_wa_req_wait = fsm == FSM_WA_REQ_WAIT;
wire fsm_wd_req_wait = fsm == FSM_WD_REQ_WAIT;
wire fsm_rd_rsp_wait = fsm == FSM_RD_RSP_WAIT;
wire fsm_wr_rsp_wait = fsm == FSM_WR_RSP_WAIT;

always @(*) begin case(fsm)
    FSM_IDLE       : begin
        if(enable && cpu_req && !mem_wen) begin
            // New read request
            if(axi_rd_req) begin
                n_fsm  = FSM_RD_RSP_WAIT;
            end else begin
                n_fsm  = FSM_RD_REQ_WAIT;
            end
        end else if(enable && cpu_req && mem_wen) begin
            // New write request
            if(axi_aw_req && axi_wd_req) begin
                n_fsm = FSM_WR_RSP_WAIT;
            end else if(axi_aw_req) begin
                n_fsm = FSM_WD_REQ_WAIT;
            end else if(axi_wd_req) begin
                n_fsm = FSM_WA_REQ_WAIT;
            end else begin
                n_fsm = FSM_WR_REQ_WAIT;
            end
        end else begin
            n_fsm = FSM_IDLE;
        end
    end
    FSM_RD_REQ_WAIT: begin
        // Has the read request been sent yet?
        n_fsm = axi_rd_req ? FSM_RD_RSP_WAIT : FSM_RD_REQ_WAIT;
    end
    FSM_WR_REQ_WAIT: begin
        // Has any of the write address/data request been accepted yet?
        if(axi_aw_req && axi_wd_req) begin
            n_fsm = FSM_WR_RSP_WAIT;
        end else if(axi_aw_req) begin
            n_fsm = FSM_WD_REQ_WAIT;
        end else if(axi_wd_req) begin
            n_fsm = FSM_WA_REQ_WAIT;
        end else begin
            n_fsm = FSM_WR_REQ_WAIT;
        end
    end
    FSM_WA_REQ_WAIT: begin
        // Waiting for write address to be sent
        n_fsm = axi_aw_req ? FSM_WR_RSP_WAIT : FSM_WA_REQ_WAIT;
    end
    FSM_WD_REQ_WAIT: begin
        // Waiting for write data to be snet.
        n_fsm = axi_wd_req ? FSM_WR_RSP_WAIT : FSM_WD_REQ_WAIT;
    end
    FSM_RD_RSP_WAIT: begin
        // Waiting for read response to be accepted.
        n_fsm = axi_rd_rsp ? FSM_IDLE        : FSM_RD_RSP_WAIT;
    end
    FSM_WR_RSP_WAIT: begin
        // Waiting for write response to be accepted.
        n_fsm = axi_wr_rsp ? FSM_IDLE        : FSM_WR_RSP_WAIT;
    end
    default        : begin
        n_fsm = FSM_IDLE;
    end
endcase end

always @(posedge m0_aclk) begin
    if(!m0_aresetn) begin
        fsm <= FSM_IDLE;
    end else begin
        fsm <= n_fsm;
    end
end


//
// Assumptions which we require to be true for all formal proofs.
`ifdef FORMAL

// Track the number of outstanding read requests.
reg  [2:0]   reads_outstanding;
wire [2:0] n_reads_outstanding = reads_outstanding + axi_rd_req - axi_rd_rsp;

always @(posedge m0_aclk) begin
    if(!m0_aresetn) begin
        reads_outstanding <= 'b0;
    end else begin
        reads_outstanding <= n_reads_outstanding;
    end
end

// Track the number of outstanding write requests.
reg  [2:0]   writes_outstanding;
wire [2:0] n_writes_outstanding = writes_outstanding + axi_aw_req - axi_wr_rsp;

always @(posedge m0_aclk) begin
    if(!m0_aresetn) begin
        writes_outstanding <= 'b0;
    end else begin
        writes_outstanding <= n_writes_outstanding;
    end
end

always @(posedge m0_aclk) begin

    // Assume that the read response channel behaves itself
    // in terms of signal stability.
    if($past(m0_rvalid) && !$past(m0_rready)) begin
        assume($stable(m0_rdata));
        assume($stable(m0_rresp));
    end

    // Assume that the write response channel behaves itself
    // in terms of signal stability.
    if($past(m0_bvalid) && !$past(m0_bready)) begin
        assume($stable(m0_bresp));
    end
    
    // No unexpected read responses.
    if(reads_outstanding == 0) begin
        assume(m0_rvalid == 1'b0);
    end
    
    // No unexpected write responses.
    if(writes_outstanding == 0) begin
        assume(m0_bvalid == 1'b0);
    end

end

`endif


//
// Assertions which we require to be true.
`ifdef FORMAL_CPU_BUS_AXI_BRIDGE

initial assume(!m0_aresetn);

always @(posedge m0_aclk) if(m0_aresetn && $stable(m0_aresetn)) begin
    
    // Address read channel
    if($past(m0_arvalid) && !$past(m0_arready)) begin
        assert($stable(m0_arvalid));
        assert($stable(m0_araddr ));
        assert($stable(m0_arprot ));
    end

    // Address write channel
    if($past(m0_awvalid) && !$past(m0_awready)) begin
        assert($stable(m0_awvalid));
        assert($stable(m0_awaddr ));
        assert($stable(m0_awprot ));
    end

    // Write data channel
    if($past(m0_wvalid) && !$past(m0_wready)) begin
        assert($stable(m0_wvalid));
        assert($stable(m0_wdata ));
        assert($stable(m0_wstrb ));
    end

    // Read data channel
    if($past(m0_rvalid) && !$past(m0_rready)) begin
        assert($stable(m0_rvalid));
    end
    
    // Write response channel
    if($past(m0_bvalid) && !$past(m0_bready)) begin
        assert($stable(m0_bvalid));
    end

end

`endif

endmodule

