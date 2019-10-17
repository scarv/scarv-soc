
//
// module: ic_cpu_bus_mux
//
//  Responsible for multiplexing 2 CPU request buses onto
//  a single one.
//
//  Note: the mux will block new requests while there is an
//  outstanding response.
//
//  Note: The S0 port has priority over the S1 port.
//
module ic_cpu_bus_mux (

input  wire        g_clk          ,
input  wire        g_resetn       ,

input  wire        s0_mem_req     , // Start memory request
input  wire        s0_mem_wen     , // Write enable
input  wire [ 3:0] s0_mem_strb    , // Write strobe
input  wire [31:0] s0_mem_wdata   , // Write data
input  wire [31:0] s0_mem_addr    , // Read/Write address
output wire        s0_mem_gnt     , // request accepted
output wire        s0_mem_recv    , // memory recieve response.
input  wire        s0_mem_ack     , // memory ack response.
output wire        s0_mem_error   , // Error
output wire [31:0] s0_mem_rdata   , // Read data

input  wire        s1_mem_req     , // Start memory request
input  wire        s1_mem_wen     , // Write enable
input  wire [ 3:0] s1_mem_strb    , // Write strobe
input  wire [31:0] s1_mem_wdata   , // Write data
input  wire [31:0] s1_mem_addr    , // Read/Write address
output wire        s1_mem_gnt     , // request accepted
output wire        s1_mem_recv    , // memory recieve response.
input  wire        s1_mem_ack     , // memory ack response.
output wire        s1_mem_error   , // Error
output wire [31:0] s1_mem_rdata   , // Read data

output wire        m0_mem_req     , // Start memory request
output wire        m0_mem_wen     , // Write enable
output wire [ 3:0] m0_mem_strb    , // Write strobe
output wire [31:0] m0_mem_wdata   , // Write data
output wire [31:0] m0_mem_addr    , // Read/Write address
input  wire        m0_mem_gnt     , // request accepted
input  wire        m0_mem_recv    , // memory recieve response.
output wire        m0_mem_ack     , // memory ack response.
input  wire        m0_mem_error   , // Error
input  wire [31:0] m0_mem_rdata     // Read data

);

//
// Response data
// ------------------------------------------------------------

assign s0_mem_error     = m0_mem_error;
assign s0_mem_rdata     = m0_mem_rdata;

assign s1_mem_error     = m0_mem_error;
assign s1_mem_rdata     = m0_mem_rdata;

//
// Request tracking.
// ------------------------------------------------------------

reg  s0_delayed_req;
reg  s1_delayed_req;

wire n_s0_delayed_req = s0_mem_req && !s0_mem_gnt;
wire n_s1_delayed_req = s1_mem_req && !s1_mem_gnt;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        s0_delayed_req <= 1'b0;
        s1_delayed_req <= 1'b0;
    end else begin
        s0_delayed_req <= n_s0_delayed_req;
        s1_delayed_req <= n_s1_delayed_req;
    end
end

//
// Request channel multiplexing.
// ------------------------------------------------------------

reg    hold_s1_req;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        hold_s1_req <= 1'b0;
    end else if(s1_mem_req && s1_mem_gnt) begin
        hold_s1_req <= 1'b0;
    end else begin
        hold_s1_req <= s1_mem_req && !s0_mem_req;
    end
end

wire   route_s0_req = s0_mem_req && !hold_s1_req;

assign m0_mem_req   = s0_mem_req || s1_mem_req;

assign m0_mem_wen   = route_s0_req ? s0_mem_wen   : s1_mem_wen    ;
assign m0_mem_addr  = route_s0_req ? s0_mem_addr  : s1_mem_addr   ;
assign m0_mem_strb  = route_s0_req ? s0_mem_strb  : s1_mem_strb   ;
assign m0_mem_wdata = route_s0_req ? s0_mem_wdata : s1_mem_wdata  ;

//
// Response tracking.
// ------------------------------------------------------------

// Is there an outstanding response due for s0/s1?
reg  s0_rsp_out;
reg  s1_rsp_out;
        
wire n_s0_rsp_out =  (s0_mem_req  && s0_mem_gnt || s0_rsp_out) &&
                    !(s0_mem_recv && s0_mem_ack);

wire n_s1_rsp_out =  (s1_mem_req  && s1_mem_gnt || s1_rsp_out) &&
                    !(s1_mem_recv && s1_mem_ack);

always @(posedge g_clk) begin
    if(!g_resetn) begin
        s0_rsp_out <= 1'b0;
        s1_rsp_out <= 1'b0;
    end else begin
        s0_rsp_out <= n_s0_rsp_out;
        s1_rsp_out <= n_s1_rsp_out;
    end
end

//
// Response channel de-multiplexing.
// ------------------------------------------------------------

assign s0_mem_recv  = s0_rsp_out && m0_mem_recv;
assign s1_mem_recv  = s1_rsp_out && m0_mem_recv;

assign m0_mem_ack   = s0_rsp_out ? s0_mem_ack : s1_mem_ack;

endmodule
