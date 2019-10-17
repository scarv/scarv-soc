
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

output  reg        route_periph_rsp

);

reg    n_route_periph_rsp ;

assign periph_ack   = cpu_ack && route_periph_rsp;

always @(*) begin
    if(route_periph_rsp) begin
        if(periph_recv && !periph_ack) begin
            // Outstanding response not yet accepted by the core.
            n_route_periph_rsp = 1'b1;
        end else if(periph_recv && periph_ack) begin
            // Response accepted by the core, check for new request.
            n_route_periph_rsp = periph_req && periph_gnt;
        end else begin
            // No response yet seen but it's still outstanding.
            n_route_periph_rsp = 1'b1;
        end
    end else begin
        // Check for new requests mapping to this interface.
        n_route_periph_rsp =  periph_req && periph_gnt;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        route_periph_rsp <= 1'b0;
    end else begin
        route_periph_rsp <= n_route_periph_rsp;
    end
end

endmodule
