
//
// module: ic_rsp_router
//
//  Keeps track of requests to different peripherals and
//  asserts when their responses should be routed back to
//  the CPU.
//
module ic_rsp_router (

input  wire        g_clk            ,
input  wire        g_resetn         ,

input  wire        cpu_ack          ,
input  wire        periph_req       ,
output wire        periph_ack       ,
input  wire        periph_recv      ,
input  wire        periph_gnt       ,

output  wire       route_periph_rsp

);

reg  [1:0] reqs_outstanding;

wire new_req = periph_req  && periph_gnt;
wire new_rsp = periph_recv && periph_ack;

wire [1:0] n_reqs_outstanding = reqs_outstanding + {1'b0, new_req} - 
                                                   {1'b0, new_rsp} ;

assign route_periph_rsp = |reqs_outstanding;

assign periph_ack       = |reqs_outstanding && cpu_ack;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reqs_outstanding <= 0;
    end else begin
        reqs_outstanding <= n_reqs_outstanding;
    end
end

endmodule
