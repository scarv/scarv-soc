
//
// module: lattice_top
//
//  Top level module for the lattice FPGA implementation flow.
//
//
module lattice_top (

input  wire        clki             ,
input  wire        resetn            

);


// Size of the ROM memory in bytes.
parameter           BRAM_ROM_SIZE      = 1024;

// Size of the RAM memory in bytes.
parameter           BRAM_RAM_SIZE      = 1024;

// Turn off the AXI bridge, since it isn't being used.
parameter           IC_ENABLE_AXI_BRIDGE = 0;

//
// Clock / reset buffering.
// ------------------------------------------------------------

wire g_clk      ; // Buffered clock signal
wire g_resetn   ; // Global reset - synchronous active low.

assign g_resetn = resetn;

// Builtin clock buffer.
SB_GB i_clk_gb (
.USER_SIGNAL_TO_GLOBAL_BUFFER(clki  ),
.GLOBAL_BUFFER_OUTPUT        (g_clk )
);

//
// Stub out the external interrupts.
// ------------------------------------------------------------

wire        cpu_int_nmi       = 0; // Non-maskable interrupt.
wire        cpu_int_external  = 0; // External interrupt trigger line.
wire [ 3:0] cpu_int_ext_cause = 0; // External interrupt cause
wire        cpu_int_software  = 0; // Software interrupt trigger line.
                             
//
// Stub out the AXI interface as it is not used here.
// ------------------------------------------------------------

wire        m0_awvalid           ; //
wire        m0_awready        = 0; //
wire [31:0] m0_awaddr            ; //
wire [ 2:0] m0_awprot            ; //
wire        m0_wvalid            ; //
wire        m0_wready         = 0; //
wire [31:0] m0_wdata             ; //
wire [ 3:0] m0_wstrb             ; //
wire        m0_bvalid         = 0; //
wire        m0_bready            ; //
wire [ 1:0] m0_bresp          = 0; //
wire        m0_arvalid           ; //
wire        m0_arready        = 0; //
wire [31:0] m0_araddr            ; //
wire [ 2:0] m0_arprot            ; //
wire        m0_rvalid         = 0; //
wire        m0_rready            ; //
wire [ 1:0] m0_rresp          = 0; //
wire [31:0] m0_rdata          = 0; //

//
// Instance the inner layer of the SoC only
// ------------------------------------------------------------
scarv_soc #(
.BRAM_ROM_SIZE(BRAM_ROM_SIZE),
.BRAM_RAM_SIZE(BRAM_RAM_SIZE),
.IC_ENABLE_AXI_BRIDGE(IC_ENABLE_AXI_BRIDGE)
) i_scarv_soc (
.g_clk            (g_clk            ),
.g_resetn         (g_resetn         ),
.cpu_int_nmi      (cpu_int_nmi      ), // Non-maskable interrupt.
.cpu_int_external (cpu_int_external ), // External interrupt trigger line.
.cpu_int_ext_cause(cpu_int_ext_cause), // External interrupt cause
.cpu_int_software (cpu_int_software ), // Software interrupt trigger line.
.m0_awvalid       (m0_awvalid       ), //
.m0_awready       (m0_awready       ), //
.m0_awaddr        (m0_awaddr        ), //
.m0_awprot        (m0_awprot        ), //
.m0_wvalid        (m0_wvalid        ), //
.m0_wready        (m0_wready        ), //
.m0_wdata         (m0_wdata         ), //
.m0_wstrb         (m0_wstrb         ), //
.m0_bvalid        (m0_bvalid        ), //
.m0_bready        (m0_bready        ), //
.m0_bresp         (m0_bresp         ), //
.m0_arvalid       (m0_arvalid       ), //
.m0_arready       (m0_arready       ), //
.m0_araddr        (m0_araddr        ), //
.m0_arprot        (m0_arprot        ), //
.m0_rvalid        (m0_rvalid        ), //
.m0_rready        (m0_rready        ), //
.m0_rresp         (m0_rresp         ), //
.m0_rdata         (m0_rdata         )  //
);


endmodule
