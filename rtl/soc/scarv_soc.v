
//
// module: scarv_soc
//
//  Top level of the SCARV SoC core module.
//
module scarv_soc (
input  wire        g_clk            ,
input  wire        g_resetn          
);

//
// SCARV CPU Parameters
// ------------------------------------------------------------

// Value taken by the PC on a reset.
parameter SCARV_CPU_PC_RESET_VALUE = 32'h1000_0000;

//
// SCARV CPU Interface Wires
// ------------------------------------------------------------

wire [31:0] cpu_trs_pc          ; // Trace program counter.
wire [31:0] cpu_trs_instr       ; // Trace instruction.
wire        cpu_trs_valid       ; // Trace output valid.

wire [31:0] cpu_leak_prng       ; // Current PRNG value.
wire        cpu_leak_fence_unc0 ; // uncore 0 fence
wire        cpu_leak_fence_unc1 ; // uncore 1 fence
wire        cpu_leak_fence_unc2 ; // uncore 2 fence

wire        cpu_rng_req_valid   ; // Signal a new request to the RNG
wire [ 2:0] cpu_rng_req_op      ; // Operation to perform on the RNG
wire [31:0] cpu_rng_req_data    ; // Suplementary seed/init data
wire        cpu_rng_req_ready   =1'b1; // RNG accepts request
wire        cpu_rng_rsp_valid   =1'b1; // RNG response data valid
wire [ 2:0] cpu_rng_rsp_status  ; // RNG status
wire [31:0] cpu_rng_rsp_data    ; // RNG response / sample data.
wire        cpu_rng_rsp_ready   ; // CPU accepts response.

wire        cpu_int_external    =1'b0; // External interrupt trigger line.
wire        cpu_int_software    =1'b0; // Software interrupt trigger line.

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


//
// SCARV CPU core instance.
// ------------------------------------------------------------

frv_core #(
.FRV_PC_RESET_VALUE (SCARV_CPU_PC_RESET_VALUE   ),
.TRACE_INSTR_WORD   (1'b0                       ),
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
.int_external   (cpu_int_external   ), // External interrupt trigger line.
.int_software   (cpu_int_software   ), // Software interrupt trigger line.
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

ic_top i_ic_top (
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
.ram_imem_rdata   (ram_imem_rdata   )  // Read data
);

endmodule
