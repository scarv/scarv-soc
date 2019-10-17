
//
// module: scarv_soc_bram_single
//
//  A single port BRAM model.
//
module scarv_soc_bram_single(

input  wire         clka        ,
input  wire         rsta        ,
input  wire         ena         ,
input  wire [ 3:0]  wea         ,
input  wire [13:0]  addra       ,
input  wire [31:0]  dina        ,
output reg  [31:0]  douta        

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

wire [31:0] read_data = {
    mem[idx_a + 3],
    mem[idx_a + 2],
    mem[idx_a + 1],
    mem[idx_a + 0]
};

wire is_write = |wea;

// Reads
always @(posedge clka) begin
    if(rsta) begin
        douta <= 0;
    end else if(ena) begin
        douta <= read_data;
    end
end

//
// Port a writes
always @(posedge clka) if(ena) begin
    mem[idx_a + 3] <= wea[3] ? dina[31:24] : mem[idx_a + 3];
    mem[idx_a + 2] <= wea[2] ? dina[23:16] : mem[idx_a + 2];
    mem[idx_a + 1] <= wea[1] ? dina[15: 8] : mem[idx_a + 1];
    mem[idx_a + 0] <= wea[0] ? dina[ 7: 0] : mem[idx_a + 0];
end

endmodule
