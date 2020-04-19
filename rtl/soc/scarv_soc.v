
//
// module: scarv_soc
//
//  Top level of the SCARV SoC core module.
//
module scarv_soc (
input  wire        g_clk            ,
input  wire        g_resetn         ,

input  wire        cpu_int_nmi      , // Non-maskable interrupt.
input  wire        cpu_int_external , // External interrupt trigger line.
input  wire [ 3:0] cpu_int_ext_cause, // External interrupt cause
input  wire        cpu_int_software , // Software interrupt trigger line.
                                    
output wire        m0_awvalid       , //
input  wire        m0_awready       , //
output wire [31:0] m0_awaddr        , //
output wire [ 2:0] m0_awprot        , //
                                    
output wire        m0_wvalid        , //
input  wire        m0_wready        , //
output wire [31:0] m0_wdata         , //
output wire [ 3:0] m0_wstrb         , //
                                    
input  wire        m0_bvalid        , //
output wire        m0_bready        , //
input  wire [ 1:0] m0_bresp         , //
                                    
output wire        m0_arvalid       , //
input  wire        m0_arready       , //
output wire [31:0] m0_araddr        , //
output wire [ 2:0] m0_arprot        , //
                                    
input  wire        m0_rvalid        , //
output wire        m0_rready        , //
input  wire [ 1:0] m0_rresp         , //
input  wire [31:0] m0_rdata           //
);

//
// SCARV CPU Parameters
// ------------------------------------------------------------

// Value taken by the PC on a reset.
parameter SCARV_CPU_PC_RESET_VALUE = 32'h1000_0000;

//
// BRAM Parameters
// ------------------------------------------------------------

/* verilator lint_off WIDTH */
parameter [255*8:0] BRAM_ROM_MEMH_FILE = "";
parameter [255*8:0] BRAM_RAM_MEMH_FILE = "";
/* verilator lint_on WIDTH */

// Size of the ROM memory in bytes.
parameter           BRAM_ROM_SIZE      = 1024;

// Size of the RAM memory in bytes.
parameter           BRAM_RAM_SIZE      = 262144;

// Width of ram bus signals.
localparam          RAM_W              = $clog2(BRAM_RAM_SIZE);
localparam          RAM_R              = RAM_W-1;

// RAM mask and range parameters for ic_addr_decode
localparam          MAP_RAM_MASK       = (32'hFFFF_FFFF >> RAM_W) << RAM_W; 
localparam          MAP_RAM_RANGE      = ~MAP_RAM_MASK; 

//
// Interconnect parameters
// ------------------------------------------------------------

// Turn the AXI bridge on (1) or off (0).
parameter IC_ENABLE_AXI_BRIDGE = 1;

//
// RNG Parameters
// ------------------------------------------------------------

/*
Which instance of the RNG should we use?
Valid values are one of the following strings:
- "lfsr" - A simple 32-bit linear feedback shift register.
*/
parameter RNG_TYPE = "lfsr";

//
// SCARV CPU Interface Wires
// ------------------------------------------------------------

// CPU trace signals are make verilator public so that in the verilated
// model, the testbench can probe down and interface with them.
wire [31:0] cpu_trs_pc    /*verilator public*/; // Trace program counter.
wire [31:0] cpu_trs_instr /*verilator public*/; // Trace instruction.
wire        cpu_trs_valid /*verilator public*/; // Trace output valid.

wire [31:0] cpu_leak_prng       ; // Current PRNG value.
wire        cpu_leak_fence_unc0 ; // uncore 0 fence
wire        cpu_leak_fence_unc1 ; // uncore 1 fence
wire        cpu_leak_fence_unc2 ; // uncore 2 fence

wire        cpu_rng_req_valid   ; // Signal a new request to the RNG
wire [ 2:0] cpu_rng_req_op      ; // Operation to perform on the RNG
wire [31:0] cpu_rng_req_data    ; // Suplementary seed/init data
wire        cpu_rng_req_ready   ; // RNG accepts request
wire        cpu_rng_rsp_valid   ; // RNG response data valid
wire [ 2:0] cpu_rng_rsp_status  ; // RNG status
wire [31:0] cpu_rng_rsp_data    ; // RNG response / sample data.
wire        cpu_rng_rsp_ready   ; // CPU accepts response.

wire        cpu_imem_req        ; // Start memory request
wire        cpu_imem_wen        ; // Write enable
wire [3:0]  cpu_imem_strb       ; // Write strobe
wire [31:0] cpu_imem_wdata      ; // Write data
wire [31:0] cpu_imem_addr       ; // Read/Write address
wire        cpu_imem_gnt        ; // request accepted
wire        cpu_imem_recv       ; // Instruction memory recieve response.
wire        cpu_imem_ack        ; // Instruction memory ack response.
wire        cpu_imem_error      ; // Error
wire [31:0] cpu_imem_rdata      ; // Read data

wire        cpu_dmem_req        ; // Start memory request
wire        cpu_dmem_wen        ; // Write enable
wire [ 3:0] cpu_dmem_strb       ; // Write strobe
wire [31:0] cpu_dmem_wdata      ; // Write data
wire [31:0] cpu_dmem_addr       ; // Read/Write address
wire        cpu_dmem_gnt        ; // request accepted
wire        cpu_dmem_recv       ; // Data memory recieve response.
wire        cpu_dmem_ack        ; // Data memory ack response.
wire        cpu_dmem_error      ; // Error
wire [31:0] cpu_dmem_rdata      ; // Read data

wire        cpu_int_mtime       ; // Machine timer interrupt triggered.

//
// Memory peripheral routing wires.
// ------------------------------------------------------------

wire        rom_imem_req         ; // Start memory request
wire        rom_imem_wen         ; // Write enable
wire [ 3:0] rom_imem_strb        ; // Write strobe
wire [31:0] rom_imem_wdata       ; // Write data
wire [31:0] rom_imem_addr        ; // Read/Write address
wire        rom_imem_gnt         ; // request accepted
wire        rom_imem_recv        ; // Instruction memory recieve response.
wire        rom_imem_ack         ; // Instruction memory ack response.
wire        rom_imem_error       ; // Error
wire [31:0] rom_imem_rdata       ; // Read data

wire        ram_imem_req         ; // Start memory request
wire        ram_imem_wen         ; // Write enable
wire [ 3:0] ram_imem_strb        ; // Write strobe
wire [31:0] ram_imem_wdata       ; // Write data
wire [31:0] ram_imem_addr        ; // Read/Write address
wire        ram_imem_gnt         ; // request accepted
wire        ram_imem_recv        ; // Instruction memory recieve response.
wire        ram_imem_ack         ; // Instruction memory ack response.
wire        ram_imem_error       ; // Error
wire [31:0] ram_imem_rdata       ; // Read data

wire        rom_dmem_req         ; // Start memory request
wire        rom_dmem_wen         ; // Write enable
wire [ 3:0] rom_dmem_strb        ; // Write strobe
wire [31:0] rom_dmem_wdata       ; // Write data
wire [31:0] rom_dmem_addr        ; // Read/Write address
wire        rom_dmem_gnt         ; // request accepted
wire        rom_dmem_recv        ; // Instruction memory recieve response.
wire        rom_dmem_ack         ; // Instruction memory ack response.
wire        rom_dmem_error       ; // Error
wire [31:0] rom_dmem_rdata       ; // Read data

wire        ram_dmem_req         ; // Start memory request
wire        ram_dmem_wen         ; // Write enable
wire [ 3:0] ram_dmem_strb        ; // Write strobe
wire [31:0] ram_dmem_wdata       ; // Write data
wire [31:0] ram_dmem_addr        ; // Read/Write address
wire        ram_dmem_gnt         ; // request accepted
wire        ram_dmem_recv        ; // Instruction memory recieve response.
wire        ram_dmem_ack         ; // Instruction memory ack response.
wire        ram_dmem_error       ; // Error
wire [31:0] ram_dmem_rdata       ; // Read data


//
// SCARV CPU core instance.
// ------------------------------------------------------------

frv_core #(
.FRV_PC_RESET_VALUE (SCARV_CPU_PC_RESET_VALUE   ),
.TRACE_INSTR_WORD   (1'b1                       ),
.BRAM_REGFILE       (1'b1                       )
) i_scarv_cpu(
.g_clk          (g_clk              ), // global clock
.g_resetn       (g_resetn           ), // synchronous reset
.trs_pc         (cpu_trs_pc         ), // Trace program counter.
.trs_instr      (cpu_trs_instr      ), // Trace instruction.
.trs_valid      (cpu_trs_valid      ), // Trace output valid.
.leak_prng      (cpu_leak_prng      ), // Current PRNG value.
.leak_fence_unc0(cpu_leak_fence_unc0), // uncore 0 fence
.leak_fence_unc1(cpu_leak_fence_unc1), // uncore 1 fence
.leak_fence_unc2(cpu_leak_fence_unc2), // uncore 2 fence
.rng_req_valid  (cpu_rng_req_valid  ), // Signal a new request to the RNG
.rng_req_op     (cpu_rng_req_op     ), // Operation to perform on the RNG
.rng_req_data   (cpu_rng_req_data   ), // Suplementary seed/init data
.rng_req_ready  (cpu_rng_req_ready  ), // RNG accepts request
.rng_rsp_valid  (cpu_rng_rsp_valid  ), // RNG response data valid
.rng_rsp_status (cpu_rng_rsp_status ), // RNG status
.rng_rsp_data   (cpu_rng_rsp_data   ), // RNG response / sample data.
.rng_rsp_ready  (cpu_rng_rsp_ready  ), // CPU accepts response.
.int_nmi        (cpu_int_nmi        ), // Non-maskable interrupt
.int_external   (cpu_int_external   ), // External interrupt trigger line.
.int_extern_cause(cpu_int_ext_cause ), // External interrupt cause
.int_software   (cpu_int_software   ), // Software interrupt trigger line.
.int_mtime      (cpu_int_mtime      ), // Machine timer interrupt triggered.
.imem_req       (cpu_imem_req       ), // Start memory request
.imem_wen       (cpu_imem_wen       ), // Write enable
.imem_strb      (cpu_imem_strb      ), // Write strobe
.imem_wdata     (cpu_imem_wdata     ), // Write data
.imem_addr      (cpu_imem_addr      ), // Read/Write address
.imem_gnt       (cpu_imem_gnt       ), // request accepted
.imem_recv      (cpu_imem_recv      ), // Instruction memory recieve response.
.imem_ack       (cpu_imem_ack       ), // Instruction memory ack response.
.imem_error     (cpu_imem_error     ), // Error
.imem_rdata     (cpu_imem_rdata     ), // Read data
.dmem_req       (cpu_dmem_req       ), // Start memory request
.dmem_wen       (cpu_dmem_wen       ), // Write enable
.dmem_strb      (cpu_dmem_strb      ), // Write strobe
.dmem_wdata     (cpu_dmem_wdata     ), // Write data
.dmem_addr      (cpu_dmem_addr      ), // Read/Write address
.dmem_gnt       (cpu_dmem_gnt       ), // request accepted
.dmem_recv      (cpu_dmem_recv      ), // Data memory recieve response.
.dmem_ack       (cpu_dmem_ack       ), // Data memory ack response.
.dmem_error     (cpu_dmem_error     ), // Error
.dmem_rdata     (cpu_dmem_rdata     )  // Read data
);


//
// Memory Interconnect Instance
// ------------------------------------------------------------

ic_top #(
.ENABLE_AXI_BRIDGE(IC_ENABLE_AXI_BRIDGE),
.MAP_RAM_MASK     (MAP_RAM_MASK        ),
.MAP_RAM_RANGE    (MAP_RAM_RANGE       )
) i_ic_top (
.g_clk            (g_clk            ),
.g_resetn         (g_resetn         ),
.cpu_imem_req     (cpu_imem_req     ), // Start memory request
.cpu_imem_wen     (cpu_imem_wen     ), // Write enable
.cpu_imem_strb    (cpu_imem_strb    ), // Write strobe
.cpu_imem_wdata   (cpu_imem_wdata   ), // Write data
.cpu_imem_addr    (cpu_imem_addr    ), // Read/Write address
.cpu_imem_gnt     (cpu_imem_gnt     ), // request accepted
.cpu_imem_recv    (cpu_imem_recv    ), // Instruction memory recieve response.
.cpu_imem_ack     (cpu_imem_ack     ), // Instruction memory ack response.
.cpu_imem_error   (cpu_imem_error   ), // Error
.cpu_imem_rdata   (cpu_imem_rdata   ), // Read data
.cpu_dmem_req     (cpu_dmem_req     ), // Start memory request
.cpu_dmem_wen     (cpu_dmem_wen     ), // Write enable
.cpu_dmem_strb    (cpu_dmem_strb    ), // Write strobe
.cpu_dmem_wdata   (cpu_dmem_wdata   ), // Write data
.cpu_dmem_addr    (cpu_dmem_addr    ), // Read/Write address
.cpu_dmem_gnt     (cpu_dmem_gnt     ), // request accepted
.cpu_dmem_recv    (cpu_dmem_recv    ), // Data memory recieve response.
.cpu_dmem_ack     (cpu_dmem_ack     ), // Data memory ack response.
.cpu_dmem_error   (cpu_dmem_error   ), // Error
.cpu_dmem_rdata   (cpu_dmem_rdata   ), // Read data
.rom_imem_req     (rom_imem_req     ), // Start memory request
.rom_imem_wen     (rom_imem_wen     ), // Write enable
.rom_imem_strb    (rom_imem_strb    ), // Write strobe
.rom_imem_wdata   (rom_imem_wdata   ), // Write data
.rom_imem_addr    (rom_imem_addr    ), // Read/Write address
.rom_imem_gnt     (rom_imem_gnt     ), // request accepted
.rom_imem_recv    (rom_imem_recv    ), // Instruction memory recieve response.
.rom_imem_ack     (rom_imem_ack     ), // Instruction memory ack response.
.rom_imem_error   (rom_imem_error   ), // Error
.rom_imem_rdata   (rom_imem_rdata   ), // Read data
.ram_imem_req     (ram_imem_req     ), // Start memory request
.ram_imem_wen     (ram_imem_wen     ), // Write enable
.ram_imem_strb    (ram_imem_strb    ), // Write strobe
.ram_imem_wdata   (ram_imem_wdata   ), // Write data
.ram_imem_addr    (ram_imem_addr    ), // Read/Write address
.ram_imem_gnt     (ram_imem_gnt     ), // request accepted
.ram_imem_recv    (ram_imem_recv    ), // Instruction memory recieve response.
.ram_imem_ack     (ram_imem_ack     ), // Instruction memory ack response.
.ram_imem_error   (ram_imem_error   ), // Error
.ram_imem_rdata   (ram_imem_rdata   ), // Read data
.rom_dmem_req     (rom_dmem_req     ), // Start memory request
.rom_dmem_wen     (rom_dmem_wen     ), // Write enable
.rom_dmem_strb    (rom_dmem_strb    ), // Write strobe
.rom_dmem_wdata   (rom_dmem_wdata   ), // Write data
.rom_dmem_addr    (rom_dmem_addr    ), // Read/Write address
.rom_dmem_gnt     (rom_dmem_gnt     ), // request accepted
.rom_dmem_recv    (rom_dmem_recv    ), // Instruction memory recieve response.
.rom_dmem_ack     (rom_dmem_ack     ), // Instruction memory ack response.
.rom_dmem_error   (rom_dmem_error   ), // Error
.rom_dmem_rdata   (rom_dmem_rdata   ), // Read data
.ram_dmem_req     (ram_dmem_req     ), // Start memory request
.ram_dmem_wen     (ram_dmem_wen     ), // Write enable
.ram_dmem_strb    (ram_dmem_strb    ), // Write strobe
.ram_dmem_wdata   (ram_dmem_wdata   ), // Write data
.ram_dmem_addr    (ram_dmem_addr    ), // Read/Write address
.ram_dmem_gnt     (ram_dmem_gnt     ), // request accepted
.ram_dmem_recv    (ram_dmem_recv    ), // Instruction memory recieve response.
.ram_dmem_ack     (ram_dmem_ack     ), // Instruction memory ack response.
.ram_dmem_error   (ram_dmem_error   ), // Error
.ram_dmem_rdata   (ram_dmem_rdata   ), // Read data
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

//
// RNG instances
// ------------------------------------------------------------

scarv_rng_top #(
.RNG_TYPE(RNG_TYPE)
) i_scarv_rng_top (
.g_clk          (g_clk              ), // global clock
.g_resetn       (g_resetn           ), // synchronous reset
.rng_req_valid  (cpu_rng_req_valid  ), // Signal a new request to the RNG
.rng_req_op     (cpu_rng_req_op     ), // Operation to perform on the RNG
.rng_req_data   (cpu_rng_req_data   ), // Suplementary seed/init data
.rng_req_ready  (cpu_rng_req_ready  ), // RNG accepts request
.rng_rsp_valid  (cpu_rng_rsp_valid  ), // RNG response data valid
.rng_rsp_status (cpu_rng_rsp_status ), // RNG status
.rng_rsp_data   (cpu_rng_rsp_data   ), // RNG response / sample data.
.rng_rsp_ready  (cpu_rng_rsp_ready  )  // CPU accepts response.
);

//
// ROM / RAM instances
// ------------------------------------------------------------

wire         bram_reset = !g_resetn;

//
// ROM

wire         rom_a_bram_cen    ;
wire  [31:0] rom_a_bram_addr   ;
wire  [31:0] rom_a_bram_wdata  ;
wire  [ 3:0] rom_a_bram_wstrb  ;
wire  [31:0] rom_a_bram_rdata  ;

wire         rom_b_bram_cen    ;
wire  [31:0] rom_b_bram_addr   ;
wire  [31:0] rom_b_bram_wdata  ;
wire  [ 3:0] rom_b_bram_wstrb  ;
wire  [31:0] rom_b_bram_rdata  ;

ic_cpu_bus_bram_bridge i_rom_imem_bus_bridge(
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.bram_cen    (rom_a_bram_cen    ),
.bram_addr   (rom_a_bram_addr   ),
.bram_wdata  (rom_a_bram_wdata  ),
.bram_wstrb  (rom_a_bram_wstrb  ),
.bram_stall  (1'b0              ),
.bram_rdata  (rom_a_bram_rdata  ),
.enable      (rom_imem_req      ), // Enable requests / does addr map?
.mem_req     (rom_imem_req      ), // Start memory request
.mem_gnt     (rom_imem_gnt      ), // request accepted
.mem_wen     (rom_imem_wen      ), // Write enable
.mem_strb    (rom_imem_strb     ), // Write strobe
.mem_wdata   (rom_imem_wdata    ), // Write data
.mem_addr    (rom_imem_addr     ), // Read/Write address
.mem_recv    (rom_imem_recv     ), // Instruction memory recieve response.
.mem_ack     (rom_imem_ack      ), // Instruction memory ack response.
.mem_error   (rom_imem_error    ), // Error
.mem_rdata   (rom_imem_rdata    )  // Read data
);

ic_cpu_bus_bram_bridge i_rom_dmem_bus_bridge(
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.bram_cen    (rom_b_bram_cen    ),
.bram_addr   (rom_b_bram_addr   ),
.bram_wdata  (rom_b_bram_wdata  ),
.bram_wstrb  (rom_b_bram_wstrb  ),
.bram_stall  (1'b0              ),
.bram_rdata  (rom_b_bram_rdata  ),
.enable      (rom_dmem_req      ), // Enable requests / does addr map?
.mem_req     (rom_dmem_req      ), // Start memory request
.mem_gnt     (rom_dmem_gnt      ), // request accepted
.mem_wen     (rom_dmem_wen      ), // Write enable
.mem_strb    (rom_dmem_strb     ), // Write strobe
.mem_wdata   (rom_dmem_wdata    ), // Write data
.mem_addr    (rom_dmem_addr     ), // Read/Write address
.mem_recv    (rom_dmem_recv     ), // Instruction memory recieve response.
.mem_ack     (rom_dmem_ack      ), // Instruction memory ack response.
.mem_error   (rom_dmem_error    ), // Error
.mem_rdata   (rom_dmem_rdata    )  // Read data
);

scarv_soc_bram_dual #(
.MEMH_FILE(BRAM_ROM_MEMH_FILE),
.DEPTH    (BRAM_ROM_SIZE     ),
.WRITE_EN (0                 )
) i_rom (
.clka (g_clk                ),
.rsta (bram_reset           ),
.ena  (rom_a_bram_cen       ),
.wea  (rom_a_bram_wstrb     ),
.addra(rom_a_bram_addr[ 9:0]),
.dina (rom_a_bram_wdata     ),
.douta(rom_a_bram_rdata     ),
.enb  (rom_b_bram_cen       ),
.web  (rom_b_bram_wstrb     ),
.addrb(rom_b_bram_addr[ 9:0]),
.dinb (rom_b_bram_wdata     ),
.doutb(rom_b_bram_rdata     ) 
);

//
// RAM

wire         ram_a_bram_cen    ;
wire  [31:0] ram_a_bram_addr   ;
wire  [31:0] ram_a_bram_wdata  ;
wire  [ 3:0] ram_a_bram_wstrb  ;
wire  [31:0] ram_a_bram_rdata  ;

wire         ram_b_bram_cen    ;
wire  [31:0] ram_b_bram_addr   ;
wire  [31:0] ram_b_bram_wdata  ;
wire  [ 3:0] ram_b_bram_wstrb  ;
wire  [31:0] ram_b_bram_rdata  ;

ic_cpu_bus_bram_bridge i_ram_imem_bus_bridge(
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.bram_cen    (ram_a_bram_cen    ),
.bram_addr   (ram_a_bram_addr   ),
.bram_wdata  (ram_a_bram_wdata  ),
.bram_wstrb  (ram_a_bram_wstrb  ),
.bram_stall  (1'b0              ),
.bram_rdata  (ram_a_bram_rdata  ),
.enable      (ram_imem_req      ), // Enable requests / does addr map?
.mem_req     (ram_imem_req      ), // Start memory request
.mem_gnt     (ram_imem_gnt      ), // request accepted
.mem_wen     (ram_imem_wen      ), // Write enable
.mem_strb    (ram_imem_strb     ), // Write strobe
.mem_wdata   (ram_imem_wdata    ), // Write data
.mem_addr    (ram_imem_addr     ), // Read/Write address
.mem_recv    (ram_imem_recv     ), // Instruction memory recieve response.
.mem_ack     (ram_imem_ack      ), // Instruction memory ack response.
.mem_error   (ram_imem_error    ), // Error
.mem_rdata   (ram_imem_rdata    )  // Read data
);

ic_cpu_bus_bram_bridge i_ram_dmem_bus_bridge(
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.bram_cen    (ram_b_bram_cen    ),
.bram_addr   (ram_b_bram_addr   ),
.bram_wdata  (ram_b_bram_wdata  ),
.bram_wstrb  (ram_b_bram_wstrb  ),
.bram_stall  (1'b0              ),
.bram_rdata  (ram_b_bram_rdata  ),
.enable      (ram_dmem_req      ), // Enable requests / does addr map?
.mem_req     (ram_dmem_req      ), // Start memory request
.mem_gnt     (ram_dmem_gnt      ), // request accepted
.mem_wen     (ram_dmem_wen      ), // Write enable
.mem_strb    (ram_dmem_strb     ), // Write strobe
.mem_wdata   (ram_dmem_wdata    ), // Write data
.mem_addr    (ram_dmem_addr     ), // Read/Write address
.mem_recv    (ram_dmem_recv     ), // Instruction memory recieve response.
.mem_ack     (ram_dmem_ack      ), // Instruction memory ack response.
.mem_error   (ram_dmem_error    ), // Error
.mem_rdata   (ram_dmem_rdata    )  // Read data
);

scarv_soc_bram_dual #(
.MEMH_FILE(BRAM_RAM_MEMH_FILE),
.DEPTH    (BRAM_RAM_SIZE     ),
.WRITE_EN (1                 )
) i_ram (
.clka (g_clk                ),
.rsta (bram_reset           ),
.ena  (ram_a_bram_cen       ),
.wea  (ram_a_bram_wstrb     ),
.addra(ram_a_bram_addr[RAM_R:0]),
.dina (ram_a_bram_wdata     ),
.douta(ram_a_bram_rdata     ),
.enb  (ram_b_bram_cen       ),
.web  (ram_b_bram_wstrb     ),
.addrb(ram_b_bram_addr[RAM_R:0]),
.dinb (ram_b_bram_wdata     ),
.doutb(ram_b_bram_rdata     ) 
);

endmodule
