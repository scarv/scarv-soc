
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
parameter [255*8:0] MEMH_FILE = "NONE";

wire [3:0] wen_a = WRITE_EN ? wea : 4'b0;
wire [3:0] wen_b = WRITE_EN ? web : 4'b0;

wire [15:0] addra_idx = addra[LW-1:2];
wire [15:0] addrb_idx = addrb[LW-1:2];

generate if(DEPTH == 1024) begin // 1Kb

BRAM_TDP_MACRO #(
.BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
.DEVICE("7SERIES"), // Target device: "7SERIES" 
.DOA_REG(0),        // Optional port A output register (0 or 1)
.DOB_REG(0),        // Optional port B output register (0 or 1)
.INIT_A(36'h0000000),  // Initial values on port A output port
.INIT_B(36'h00000000), // Initial values on port B output port
.INIT_FILE (MEMH_FILE),
.READ_WIDTH_A (32),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.READ_WIDTH_B (32),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
.WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
.WRITE_WIDTH_A(32), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_WIDTH_B(32)  // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
) BRAM_TDP_MACRO_inst (
.DOA    (douta  ), // Output port-A data, width defined by READ_WIDTH_A parameter
.DOB    (doutb  ), // Output port-B data, width defined by READ_WIDTH_B parameter
.ADDRA  (addra_idx), // Input port-A address, width defined by Port A depth
.ADDRB  (addrb_idx), // Input port-B address, width defined by Port B depth
.CLKA   (clka   ), // 1-bit input port-A clock
.CLKB   (clka   ), // 1-bit input port-B clock
.DIA    (32'b0), // Input port-A data, width defined by WRITE_WIDTH_A parameter
.DIB    (32'b0), // Input port-B data, width defined by WRITE_WIDTH_B parameter
.ENA    (ena    ), // 1-bit input port-A enable
.ENB    (enb    ), // 1-bit input port-B enable
.REGCEA (ena    ), // 1-bit input port-A output register enable
.REGCEB (enb    ), // 1-bit input port-B output register enable
.RSTA   (rsta   ), // 1-bit input port-A reset
.RSTB   (rsta   ), // 1-bit input port-B reset
.WEA    (wen_a  ), // Input port-A write enable, width defined by Port A depth
.WEB    (wen_b  )  // Input port-B write enable, width defined by Port B depth
);


end else if(DEPTH == 65536) begin // 64Kb

wire en_a_lo = ena && !addra[15];
wire en_a_hi = ena &&  addra[15];

wire en_b_lo = ena && !addra[15];
wire en_b_hi = ena &&  addra[15];

reg  route_a_lo;
reg  route_b_lo;

wire [35:0] dout_a_lo;
wire [35:0] dout_b_lo;

wire [35:0] dout_a_hi;
wire [35:0] dout_b_hi;

assign douta = route_a_lo ? dout_a_lo : dout_a_hi;
assign doutb = route_b_lo ? dout_b_lo : dout_b_hi;

always @(posedge clka) begin
    if(rsta) begin
        route_a_lo <= 1'b0;
        route_b_lo <= 1'b0;
    end else begin
        route_a_lo <= en_a_lo;
        route_b_lo <= en_b_lo;
    end
end

//
// LOW 32K of the 64K BRAM
//
BRAM_TDP_MACRO #(
.BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
.DEVICE("7SERIES"), // Target device: "7SERIES" 
.DOA_REG(0),        // Optional port A output register (0 or 1)
.DOB_REG(0),        // Optional port B output register (0 or 1)
.INIT_A(36'h0000000),  // Initial values on port A output port
.INIT_B(36'h00000000), // Initial values on port B output port
.INIT_FILE (MEMH_FILE),
.READ_WIDTH_A (32),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.READ_WIDTH_B (32),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
.WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
.WRITE_WIDTH_A(32), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_WIDTH_B(32)  // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
) BRAM_TDP_MACRO_inst_lo (
.DOA    (dout_a_lo), // Output port-A data, width defined by READ_WIDTH_A parameter
.DOB    (dout_b_lo), // Output port-B data, width defined by READ_WIDTH_B parameter
.ADDRA  (addra_idx), // Input port-A address, width defined by Port A depth
.ADDRB  (addrb_idx), // Input port-B address, width defined by Port B depth
.CLKA   (clka   ), // 1-bit input port-A clock
.CLKB   (clka   ), // 1-bit input port-B clock
.DIA    ({2'b00,dina}), // Input port-A data, width defined by WRITE_WIDTH_A parameter
.DIB    ({2'b00,dinb}), // Input port-B data, width defined by WRITE_WIDTH_B parameter
.ENA    (en_a_lo), // 1-bit input port-A enable
.ENB    (en_b_lo), // 1-bit input port-B enable
.REGCEA (en_a_lo), // 1-bit input port-A output register enable
.REGCEB (en_b_lo), // 1-bit input port-B output register enable
.RSTA   (rsta   ), // 1-bit input port-A reset
.RSTB   (rsta   ), // 1-bit input port-B reset
.WEA    (wen_a  ), // Input port-A write enable, width defined by Port A depth
.WEB    (wen_b  )  // Input port-B write enable, width defined by Port B depth
);

//
// HIGH 32K of the 64K BRAM
//
BRAM_TDP_MACRO #(
.BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
.DEVICE("7SERIES"), // Target device: "7SERIES" 
.DOA_REG(0),        // Optional port A output register (0 or 1)
.DOB_REG(0),        // Optional port B output register (0 or 1)
.INIT_A(36'h0000000),  // Initial values on port A output port
.INIT_B(36'h00000000), // Initial values on port B output port
.INIT_FILE (MEMH_FILE),
.READ_WIDTH_A (32),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.READ_WIDTH_B (32),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
.WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
.WRITE_WIDTH_A(32), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_WIDTH_B(32)  // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
) BRAM_TDP_MACRO_inst_hi (
.DOA    (dout_a_hi), // Output port-A data, width defined by READ_WIDTH_A parameter
.DOB    (dout_b_hi), // Output port-B data, width defined by READ_WIDTH_B parameter
.ADDRA  (addra_idx), // Input port-A address, width defined by Port A depth
.ADDRB  (addrb_idx), // Input port-B address, width defined by Port B depth
.CLKA   (clka   ), // 1-bit input port-A clock
.CLKB   (clka   ), // 1-bit input port-B clock
.DIA    ({2'b00,dina}), // Input port-A data, width defined by WRITE_WIDTH_A parameter
.DIB    ({2'b00,dinb}), // Input port-B data, width defined by WRITE_WIDTH_B parameter
.ENA    (en_a_hi), // 1-bit input port-A enable
.ENB    (en_b_hi), // 1-bit input port-B enable
.REGCEA (en_a_hi), // 1-bit input port-A output register enable
.REGCEB (en_b_hi), // 1-bit input port-B output register enable
.RSTA   (rsta   ), // 1-bit input port-A reset
.RSTB   (rsta   ), // 1-bit input port-B reset
.WEA    (wen_a  ), // Input port-A write enable, width defined by Port A depth
.WEB    (wen_b  )  // Input port-B write enable, width defined by Port B depth
);

end endgenerate

endmodule

