
//
// module: scarv_soc_bram_dual
//
//  A dual port BRAM model which is used for formal proofs of the SoC.
//  The entire memory is just black-boxed.
//
module scarv_soc_bram_dual (

input  wire           clka        ,
input  wire           rsta        ,

input  wire           ena         ,
input  wire [   3:0]  wea         ,
input  wire [LW-1:0]  addra       ,
input  wire [  31:0]  dina        ,
output reg  [  31:0]  douta       ,

input  wire           enb         ,
input  wire [   3:0]  web         ,
input  wire [LW-1:0]  addrb       ,
input  wire [  31:0]  dinb        ,
output reg  [  31:0]  doutb        

);

//! Can we write to this module? If 0, then it's a ROM.
parameter   WRITE_EN = 1;

//! Depth of the BRAM in bytes.
parameter   DEPTH = 1024;
localparam  LW    = $clog2(DEPTH);

//! Memory file to load. ignored in formal code.
parameter [255*8:0] MEMH_FILE = "";

reg [31:0] blackbox_read_value_a = $anyseq;
reg [31:0] blackbox_read_value_b = $anyseq;

always @(*) douta = blackbox_read_value_a;
always @(*) doutb = blackbox_read_value_b;

always @(posedge clka) begin
    if(!$past(ena)) begin
        assume($stable(douta));
    end
    if(!$past(enb)) begin
        assume($stable(doutb));
    end
end

endmodule

