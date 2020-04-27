
//
// module: scarv_soc_bram_dual
//
//  A dual port BRAM model used for blackbox synthesis using Xilinx Vivado
//  targeting a Kintex7  (XC7K) FPGA.
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
localparam NB_COL          = BRAM_DATA_WIDTH/BRAM_BYTE_WIDTH;
localparam BRAM_DEPTH      = DEPTH / NB_COL;
localparam BRAM_ADDR_WIDTH = LW;

wire [BRAM_ADDR_WIDTH-1:0] addra_idx = addra[BRAM_ADDR_WIDTH-1:2];
wire [BRAM_ADDR_WIDTH-1:0] addrb_idx = addrb[BRAM_ADDR_WIDTH-1:2];

reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] BRAM [BRAM_DEPTH-1:0];
reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] ram_data_a = {(NB_COL*BRAM_BYTE_WIDTH){1'b0}};
reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] ram_data_b = {(NB_COL*BRAM_BYTE_WIDTH){1'b0}};

assign douta = ram_data_a;
assign doutb = ram_data_b;

// The following code either initializes the memory values to a specified file or to all zeros to match hardware
generate
  if (MEMH_FILE != "") begin: use_init_file
    initial begin
        $display("Loading: %s", MEMH_FILE);
        $readmemh(MEMH_FILE, BRAM, 0, BRAM_DEPTH-1);
        $display("Loaded");
    end
  end else begin: init_bram_to_zero
    integer ram_index;
    initial
      for (ram_index = 0; ram_index < BRAM_DEPTH; ram_index = ram_index + 1)
        BRAM[ram_index] = {(NB_COL*BRAM_BYTE_WIDTH){1'b0}};
  end
endgenerate

generate
genvar i;
   for (i = 0; i < NB_COL; i = i+1) begin: byte_write
     always @(posedge clka)
       if (ena)
         if (wea[i]) begin
           BRAM[addra_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= dina[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
           ram_data_a[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= dina[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end else begin
           ram_data_a[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= BRAM[addra_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end

     always @(posedge clka)
       if (enb)
         if (web[i]) begin
           BRAM[addrb_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= dinb[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
           ram_data_b[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= dinb[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end else begin
           ram_data_b[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= BRAM[addrb_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end
   end
endgenerate

endmodule

