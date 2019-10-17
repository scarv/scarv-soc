
//
// module: ic_top
//
//  Top level of the simple memory interconnect.
//
module ic_top (

input  wire        g_clk            ,
input  wire        g_resetn         ,

input  wire        cpu_imem_req     , // Start memory request
input  wire        cpu_imem_wen     , // Write enable
input  wire [ 3:0] cpu_imem_strb    , // Write strobe
input  wire [31:0] cpu_imem_wdata   , // Write data
input  wire [31:0] cpu_imem_addr    , // Read/Write address
output wire        cpu_imem_gnt     , // request accepted
output wire        cpu_imem_recv    , // Instruction memory recieve response.
input  wire        cpu_imem_ack     , // Instruction memory ack response.
output wire        cpu_imem_error   , // Error
output wire [31:0] cpu_imem_rdata   , // Read data

input  wire        cpu_dmem_req     , // Start memory request
input  wire        cpu_dmem_wen     , // Write enable
input  wire [ 3:0] cpu_dmem_strb    , // Write strobe
input  wire [31:0] cpu_dmem_wdata   , // Write data
input  wire [31:0] cpu_dmem_addr    , // Read/Write address
output wire        cpu_dmem_gnt     , // request accepted
output wire        cpu_dmem_recv    , // Data memory recieve response.
input  wire        cpu_dmem_ack     , // Data memory ack response.
output wire        cpu_dmem_error   , // Error
output wire [31:0] cpu_dmem_rdata   , // Read data

output wire        rom_imem_req     , // Start memory request
output wire        rom_imem_wen     , // Write enable
output wire [ 3:0] rom_imem_strb    , // Write strobe
output wire [31:0] rom_imem_wdata   , // Write data
output wire [31:0] rom_imem_addr    , // Read/Write address
input  wire        rom_imem_gnt     , // request accepted
input  wire        rom_imem_recv    , // Instruction memory recieve response.
output wire        rom_imem_ack     , // Instruction memory ack response.
input  wire        rom_imem_error   , // Error
input  wire [31:0] rom_imem_rdata   , // Read data

output wire        ram_imem_req     , // Start memory request
output wire        ram_imem_wen     , // Write enable
output wire [ 3:0] ram_imem_strb    , // Write strobe
output wire [31:0] ram_imem_wdata   , // Write data
output wire [31:0] ram_imem_addr    , // Read/Write address
input  wire        ram_imem_gnt     , // request accepted
input  wire        ram_imem_recv    , // Instruction memory recieve response.
output wire        ram_imem_ack     , // Instruction memory ack response.
input  wire        ram_imem_error   , // Error
input  wire [31:0] ram_imem_rdata     // Read data

);

//
// Memory map parameters.
// ------------------------------------------------------------

parameter MAP_ROM_MATCH = 32'h1000_0000;
parameter MAP_ROM_MASK  = 32'hFFFF_C000;
parameter MAP_ROM_RANGE = 32'h0000_3FFF;

parameter MAP_RAM_MATCH = 32'h2000_0000;
parameter MAP_RAM_MASK  = 32'hFFFF_0000;
parameter MAP_RAM_RANGE = 32'h0000_FFFF;

parameter MAP_AXI_MATCH = 32'h4000_0000;
parameter MAP_AXI_MASK  = 32'hF000_0000;
parameter MAP_AXI_RANGE = 32'h0FFF_FFFF;

//
// Input request address decoding.
// ------------------------------------------------------------

wire ic_imem_error    ; // Address decode error - doesn't map
wire ic_imem_route_rom; // Route to the ROM
wire ic_imem_route_ram; // Route to the RAM
wire ic_imem_route_axi; // Route to the AXI bridge.

wire ic_dmem_error    ; // Address decode error - doesn't map
wire ic_dmem_route_rom; // Route to the ROM
wire ic_dmem_route_ram; // Route to the RAM
wire ic_dmem_route_axi; // Route to the AXI bridge.

//
// Instruction <-> RAM Routing
// ------------------------------------------------------------

assign ram_imem_req   = ic_imem_route_ram && cpu_imem_req;
assign cpu_imem_gnt   = ic_imem_route_ram && ram_imem_gnt;

assign ram_imem_wen   = cpu_imem_wen  ; // Write enable
assign ram_imem_strb  = cpu_imem_strb ; // Write strobe
assign ram_imem_wdata = cpu_imem_wdata; // Write data
assign ram_imem_addr  = cpu_imem_addr ; // Read/Write address

reg    route_rsp_imem_ram   ;
reg    n_route_rsp_imem_ram ;

always @(*) begin
    if(route_rsp_imem_ram) begin
        if(ram_imem_recv && !ram_imem_ack) begin
            // Outstanding response not yet accepted by the core.
            n_route_rsp_imem_ram = 1'b1;
        end else if(ram_imem_recv && ram_imem_ack) begin
            // Response accepted by the core, check for new request.
            n_route_rsp_imem_ram = ram_imem_req && ram_imem_gnt;
        end else begin
            // No response yet seen but it's still outstanding.
            n_route_rsp_imem_ram = 1'b1;
        end
    end else begin
        // Check for new requests mapping to this interface.
        n_route_rsp_imem_ram =  ram_imem_req && ram_imem_gnt;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        route_rsp_imem_ram <= 1'b0;
    end else begin
        route_rsp_imem_ram <= n_route_rsp_imem_ram;
    end
end

//
// Instruction <-> ROM Routing
// ------------------------------------------------------------

assign rom_imem_req   = ic_imem_route_rom && cpu_imem_req;
assign cpu_imem_gnt   = ic_imem_route_rom && rom_imem_gnt;

assign rom_imem_wen   = cpu_imem_wen  ; // Write enable
assign rom_imem_strb  = cpu_imem_strb ; // Write strobe
assign rom_imem_wdata = cpu_imem_wdata; // Write data
assign rom_imem_addr  = cpu_imem_addr ; // Read/Write address

reg    route_rsp_imem_rom   ;
reg    n_route_rsp_imem_rom ;

assign rom_imem_ack   = cpu_imem_ack && route_rsp_imem_rom;

always @(*) begin
    if(route_rsp_imem_rom) begin
        if(rom_imem_recv && !rom_imem_ack) begin
            // Outstanding response not yet accepted by the core.
            n_route_rsp_imem_rom = 1'b1;
        end else if(rom_imem_recv && rom_imem_ack) begin
            // Response accepted by the core, check for new request.
            n_route_rsp_imem_rom = rom_imem_req && rom_imem_gnt;
        end else begin
            // No response yet seen but it's still outstanding.
            n_route_rsp_imem_rom = 1'b1;
        end
    end else begin
        // Check for new requests mapping to this interface.
        n_route_rsp_imem_rom =  rom_imem_req && rom_imem_gnt;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        route_rsp_imem_rom <= 1'b0;
    end else begin
        route_rsp_imem_rom <= n_route_rsp_imem_rom;
    end
end

//
// Response Routing
// ------------------------------------------------------------

assign cpu_imem_recv =
    route_rsp_imem_rom  && rom_imem_recv    ||
    route_rsp_imem_ram  && ram_imem_recv    ;

assign cpu_imem_error=
    route_rsp_imem_rom  && rom_imem_error   ||
    route_rsp_imem_ram  && ram_imem_error   ;

assign cpu_imem_rdata=
    {32{route_rsp_imem_rom}} & rom_imem_rdata   |
    {32{route_rsp_imem_ram}} & ram_imem_rdata   ;

//
// Submodule instances
// ------------------------------------------------------------

// CPU Instruction memory interface address routing.
ic_addr_decode ic_addr_decode_cpu_imem (
.g_clk        (g_clk            ),   // Global clock
.g_resetn     (g_resetn         ),   // Synchronous active low reset
.req_valid    (cpu_imem_req     ),   // Request is valid
.req_addr     (cpu_imem_addr    ),   // Request address
.req_dec_err  (ic_imem_error    ),   // Address decode error - doesn't map
.route_rom    (ic_imem_route_rom),   // Route to the ROM
.route_ram    (ic_imem_route_ram),   // Route to the RAM
.route_axi    (ic_imem_route_axi)    // Route to the AXI bridge.
);

// CPU Data memory interface address routing.
ic_addr_decode ic_addr_decode_cpu_dmem (
.g_clk        (g_clk            ),   // Global clock
.g_resetn     (g_resetn         ),   // Synchronous active low reset
.req_valid    (cpu_dmem_req     ),   // Request is valid
.req_addr     (cpu_dmem_addr    ),   // Request address
.req_dec_err  (ic_dmem_error    ),   // Address decode error - doesn't map
.route_rom    (ic_dmem_route_rom),   // Route to the ROM
.route_ram    (ic_dmem_route_ram),   // Route to the RAM
.route_axi    (ic_dmem_route_axi)    // Route to the AXI bridge.
);


endmodule
