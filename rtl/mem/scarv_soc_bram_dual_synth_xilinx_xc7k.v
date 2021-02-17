
//
// module: scarv_soc_bram_dual
//
//  A dual port BRAM model used for blackbox synthesis using Xilinx Vivado
//  targeting a Kintex7  (XC7K) FPGA.
//
module scarv_dual_ram (
input  wire         g_clk       ,
input  wire         g_resetn    ,

input  wire         a_cen       , // Start memory request
input  wire         a_wen       , // Write enable
input  wire [SW: 0] a_strb      , // Write strobe
input  wire [DW: 0] a_wdata     , // Write data
input  wire [AW: 0] a_addr      , // Read/Write address
output wire [DW: 0] a_rdata     , // Read data

input  wire         b_cen       , // Start memory request
input  wire         b_wen       , // Write enable
input  wire [SW: 0] b_strb      , // Write strobe
input  wire [DW: 0] b_wdata     , // Write data
input  wire [AW: 0] b_addr      , // Read/Write address
output wire [DW: 0] b_rdata       // Read data

);
parameter   DEPTH = 4096    ;   // Depth of RAM in words
parameter   WIDTH = 32      ;   // Width of a RAM word.
parameter [255*8-1:0] INIT_FILE=""; // Memory initialisaton file.

// Write strobe width.
localparam SW = (WIDTH / 8) - 1;

// Address lines width.
localparam AW = $clog2(DEPTH) - 1;

// Data line width
localparam DW = WIDTH - 1;

//! Can we write to this module? If 0, then it's a ROM.
parameter   WRITE_EN = 1;

localparam BRAM_DATA_WIDTH = WIDTH ;
localparam BRAM_BYTE_WIDTH = 8     ;
localparam NB_COL          = BRAM_DATA_WIDTH/BRAM_BYTE_WIDTH;
localparam BRAM_DEPTH      = (DEPTH/4) / NB_COL;
localparam BRAM_ADDR_WIDTH = $clog2(DEPTH/4);

wire [BRAM_ADDR_WIDTH-1:0] addra_idx = a_addr[BRAM_ADDR_WIDTH-1:0];
wire [BRAM_ADDR_WIDTH-1:0] addrb_idx = b_addr[BRAM_ADDR_WIDTH-1:0];

reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] BRAM [BRAM_DEPTH-1:0];
reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] ram_data_a = {(NB_COL*BRAM_BYTE_WIDTH){1'b0}};
reg [(NB_COL*BRAM_BYTE_WIDTH)-1:0] ram_data_b = {(NB_COL*BRAM_BYTE_WIDTH){1'b0}};

assign a_rdata = ram_data_a;
assign b_rdata = ram_data_b;

// The following code either initializes the memory values to a specified file or to all zeros to match hardware
generate
  if (INIT_FILE != "") begin: use_init_file
    initial begin
        $display("Loading: %s", INIT_FILE);
        $readmemh(INIT_FILE, BRAM, 0, BRAM_DEPTH-1);
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
     always @(posedge g_clk)
       if (a_cen)
         if (a_wen && a_strb[i]) begin
           BRAM[addra_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= a_wdata[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
           ram_data_a[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= a_wdata[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end else begin
           ram_data_a[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= BRAM[addra_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end

     always @(posedge g_clk)
       if (b_cen)
         if (b_wen && b_strb[i]) begin
           BRAM[addrb_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= b_wdata[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
           ram_data_b[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= b_wdata[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end else begin
           ram_data_b[(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH] <= BRAM[addrb_idx][(i+1)*BRAM_BYTE_WIDTH-1:i*BRAM_BYTE_WIDTH];
         end
   end
endgenerate

endmodule

