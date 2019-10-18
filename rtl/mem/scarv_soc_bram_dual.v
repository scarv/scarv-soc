
//
// module: scarv_soc_bram_dual
//
//  A dual port BRAM model.
//
module scarv_soc_bram_dual (

input  wire         clka        ,
input  wire         rsta        ,

input  wire         ena         ,
input  wire [ 3:0]  wea         ,
input  wire [LW-1:0]  addra       ,
input  wire [31:0]  dina        ,
output reg  [31:0]  douta       ,

input  wire         enb         ,
input  wire [ 3:0]  web         ,
input  wire [LW-1:0]  addrb       ,
input  wire [31:0]  dinb        ,
output reg  [31:0]  doutb        

);

//! Depth of the BRAM in bytes.
parameter   DEPTH = 1024;
localparam  LW    = $clog2(DEPTH);

//! Memory file to load
parameter [255*8:0] MEMH_FILE = "";

initial begin
    if(MEMH_FILE != "") begin
        $readmemh(MEMH_FILE, mem);
    end
end

reg [7:0] mem [DEPTH-1:0];

wire [LW-1:0] idx_a = {addra[LW-1:2],2'b00};
wire [LW-1:0] idx_b = {addrb[LW-1:2],2'b00};

wire [31:0] read_data_a = {
    mem[idx_a + 3],
    mem[idx_a + 2],
    mem[idx_a + 1],
    mem[idx_a + 0]
};

wire [31:0] read_data_b = {
    mem[idx_b + 3],
    mem[idx_b + 2],
    mem[idx_b + 1],
    mem[idx_b + 0]
};

`ifdef BLACKBOX_SCARV_SOC_BRAM_DUAL

reg [31:0] blackbox_read_value_a = $anyseq;
reg [31:0] blackbox_read_value_b = $anyseq;

always @(*) douta = blackbox_read_value_a;
always @(*) doutb = blackbox_read_value_b;

`else

// Reads
always @(posedge clka) begin
    if(rsta) begin
        douta <= 0;
    end else if(ena) begin
        douta <= read_data_a;
    end
end

// Reads
always @(posedge clka) begin
    if(rsta) begin
        doutb <= 0;
    end else if(enb) begin
        doutb <= read_data_b;
    end
end
`endif

//
// Port a writes
always @(posedge clka) if(ena) begin
    mem[idx_a + 3] <= wea[3] ? dina[31:24] : mem[idx_a + 3];
    mem[idx_a + 2] <= wea[2] ? dina[23:16] : mem[idx_a + 2];
    mem[idx_a + 1] <= wea[1] ? dina[15: 8] : mem[idx_a + 1];
    mem[idx_a + 0] <= wea[0] ? dina[ 7: 0] : mem[idx_a + 0];
end

//
// Port b writes
always @(posedge clka) if(enb) begin
    mem[idx_b + 3] <= web[3] ? dinb[31:24] : mem[idx_b + 3];
    mem[idx_b + 2] <= web[2] ? dinb[23:16] : mem[idx_b + 2];
    mem[idx_b + 1] <= web[1] ? dinb[15: 8] : mem[idx_b + 1];
    mem[idx_b + 0] <= web[0] ? dinb[ 7: 0] : mem[idx_b + 0];
end

endmodule

