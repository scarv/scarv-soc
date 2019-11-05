
//
// module: scarv_soc_bram_dual
//
//  A dual port BRAM model used for synthesis using the open source
//  lattice implementation flow.
//
module scarv_soc_bram_dual (

input  wire           clka        ,
input  wire           rsta        ,

input  wire           ena         ,
input  wire [   3:0]  wea         ,
input  wire [LW-1:0]  addra       ,
input  wire [  31:0]  dina        ,
output wire [  31:0]  douta       ,

input  wire           enb         ,
input  wire [   3:0]  web         ,
input  wire [LW-1:0]  addrb       ,
input  wire [  31:0]  dinb        ,
output wire [  31:0]  doutb        

);

//! Can we write to this module? If 0, then it's a ROM.
parameter   WRITE_EN = 1;

//! Depth of the BRAM in bytes.
parameter   DEPTH = 1024;
localparam  LW    = $clog2(DEPTH);

//! Memory file to load
parameter [255*8:0] MEMH_FILE = "";

localparam BRAM_DATA_WIDTH = 32    ;
localparam BRAM_BYTE_WIDTH = 8     ;
localparam NB_COL          = BRAM_DATA_WIDTH/BRAM_BYTE_WIDTH; // 4
localparam BRAM_DEPTH      = DEPTH / NB_COL;
localparam BRAM_ADDR_WIDTH = LW;

wire [BRAM_ADDR_WIDTH-1:0] addra_idx = addra[BRAM_ADDR_WIDTH-1:2];

reg [BRAM_BYTE_WIDTH-1:0] BRAM_0 [0:BRAM_DEPTH-1];
reg [BRAM_BYTE_WIDTH-1:0] BRAM_1 [0:BRAM_DEPTH-1];
reg [BRAM_BYTE_WIDTH-1:0] BRAM_2 [0:BRAM_DEPTH-1];
reg [BRAM_BYTE_WIDTH-1:0] BRAM_3 [0:BRAM_DEPTH-1];

reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] ram_data_a ;

assign douta = ram_data_a;
assign doutb = 0;

always @(posedge clka) begin
    if (ena) begin
        if (wea[0]) begin
            BRAM_0[addra_idx]<= dina[0*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH];
        end
        ram_data_a[0*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH] <= BRAM_0[addra_idx];
    end
end
always @(posedge clka) begin
    if (ena) begin
        if (wea[1]) begin
            BRAM_1[addra_idx]<= dina[1*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH];
        end
        ram_data_a[1*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH] <= BRAM_1[addra_idx];
    end
end
always @(posedge clka) begin
    if (ena) begin
        if (wea[2]) begin
            BRAM_2[addra_idx]<= dina[2*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH];
        end
        ram_data_a[2*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH] <= BRAM_2[addra_idx];
    end
end
always @(posedge clka) begin
    if (ena) begin
        if (wea[3]) begin
            BRAM_3[addra_idx]<= dina[3*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH];
        end
        ram_data_a[3*BRAM_BYTE_WIDTH+:BRAM_BYTE_WIDTH] <= BRAM_3[addra_idx];
    end
end

endmodule

