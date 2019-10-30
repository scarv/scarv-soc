
//
// module: ic_rsp_tracker
//
//  Keeps track of requests to different peripherals and records
//  the order they were made in. Used to arbitrate the order in which
//  responses are then fed back.
//
module ic_rsp_tracker(

input  wire             g_clk            ,
input  wire             g_resetn         ,

input  wire [ND-1:0]    requests         , // Incoming requests this cycle.
input  wire [ND-1:0]    responses        , // Incoming responses this cycle.
output wire [ND-1:0]    response_gnt     , // Outgoing response grants
output wire             ready              // Ready for a new request?

);

// Number of devices to arbitrate
parameter ND            = 3;

//! Maximum outstanding requests we will track.
parameter MAX_REQUESTS  = 4;

localparam PTR_SIZE     = $clog2(MAX_REQUESTS);

reg  [ND-1      :0] req_buffer [MAX_REQUESTS-1:0];

reg  [PTR_SIZE-1:0] head;
reg  [PTR_SIZE-1:0] tail;

wire [PTR_SIZE-1:0] n_head = (head + 1) >= (MAX_REQUESTS) ? 0 : head + 1;
wire [PTR_SIZE-1:0] n_tail = (tail + 1) >= (MAX_REQUESTS) ? 0 : tail + 1;

wire new_req = |requests;
wire new_rsp = |responses;

assign ready = n_tail != head || 
               n_tail == head && head != n_head;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        head <= 0;
        tail <= 0;
    end else begin
        if(new_req && ready) begin
            head <= n_head;
        end 
        if (new_rsp) begin
            tail <= n_tail;
        end
    end
end

assign response_gnt = req_buffer[tail];

integer i;
always @(posedge g_clk) begin
    if(!g_resetn) begin
        for(i = 0; i < MAX_REQUESTS; i = i + 1) begin
            req_buffer[i] <= 0;
        end
    end else if(new_req) begin
        req_buffer[head] <= requests;
    end
end

`ifdef FORMAL_IC_RSP_TRACKER

initial assume(!g_resetn);

always @(posedge g_clk) if(g_resetn && $past(g_resetn)) begin

    assert(!(new_req && !ready))

end

`endif

endmodule
