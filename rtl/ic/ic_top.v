
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
input  wire [31:0] ram_imem_rdata   , // Read data

output wire        rom_dmem_req     , // Start memory request
output wire        rom_dmem_wen     , // Write enable
output wire [ 3:0] rom_dmem_strb    , // Write strobe
output wire [31:0] rom_dmem_wdata   , // Write data
output wire [31:0] rom_dmem_addr    , // Read/Write address
input  wire        rom_dmem_gnt     , // request accepted
input  wire        rom_dmem_recv    , // Instruction memory recieve response.
output wire        rom_dmem_ack     , // Instruction memory ack response.
input  wire        rom_dmem_error   , // Error
input  wire [31:0] rom_dmem_rdata   , // Read data

output wire        ram_dmem_req     , // Start memory request
output wire        ram_dmem_wen     , // Write enable
output wire [ 3:0] ram_dmem_strb    , // Write strobe
output wire [31:0] ram_dmem_wdata   , // Write data
output wire [31:0] ram_dmem_addr    , // Read/Write address
input  wire        ram_dmem_gnt     , // request accepted
input  wire        ram_dmem_recv    , // Instruction memory recieve response.
output wire        ram_dmem_ack     , // Instruction memory ack response.
input  wire        ram_dmem_error   , // Error
input  wire [31:0] ram_dmem_rdata     // Read data

);

//
// Memory map parameters.
// ------------------------------------------------------------

parameter MAP_ROM_MATCH = 32'h1000_0000;
parameter MAP_ROM_MASK  = 32'hFFFF_C000;
parameter MAP_ROM_RANGE = 32'h0000_03FF;

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

assign ram_imem_wen   = cpu_imem_wen  ; // Write enable
assign ram_imem_strb  = cpu_imem_strb ; // Write strobe
assign ram_imem_wdata = cpu_imem_wdata; // Write data
assign ram_imem_addr  = cpu_imem_addr ; // Read/Write address

wire   route_rsp_imem_ram;

ic_rsp_router i_rsp_router_imem_ram (
.g_clk           (g_clk             ),
.g_resetn        (g_resetn          ),
.cpu_ack         (cpu_imem_ack      ),
.periph_req      (ram_imem_req      ),
.periph_ack      (ram_imem_ack      ),
.periph_recv     (ram_imem_recv     ),
.periph_gnt      (ram_imem_gnt      ),
.route_periph_rsp(route_rsp_imem_ram)
);

//
// Instruction <-> ROM Routing
// ------------------------------------------------------------

assign rom_imem_req   = ic_imem_route_rom && cpu_imem_req;

assign rom_imem_wen   = cpu_imem_wen  ; // Write enable
assign rom_imem_strb  = cpu_imem_strb ; // Write strobe
assign rom_imem_wdata = cpu_imem_wdata; // Write data
assign rom_imem_addr  = cpu_imem_addr ; // Read/Write address

wire   route_rsp_imem_rom   ;

ic_rsp_router i_rsp_router_imem_rom (
.g_clk           (g_clk             ),
.g_resetn        (g_resetn          ),
.cpu_ack         (cpu_imem_ack      ),
.periph_req      (rom_imem_req      ),
.periph_ack      (rom_imem_ack      ),
.periph_recv     (rom_imem_recv     ),
.periph_gnt      (rom_imem_gnt      ),
.route_periph_rsp(route_rsp_imem_rom)
);

//
// Data <-> RAM Routing
// ------------------------------------------------------------

assign ram_dmem_req   = ic_dmem_route_ram && cpu_dmem_req;

assign ram_dmem_wen   = cpu_dmem_wen  ; // Write enable
assign ram_dmem_strb  = cpu_dmem_strb ; // Write strobe
assign ram_dmem_wdata = cpu_dmem_wdata; // Write data
assign ram_dmem_addr  = cpu_dmem_addr ; // Read/Write address

wire   route_rsp_dmem_ram;

ic_rsp_router i_rsp_router_dmem_ram (
.g_clk           (g_clk             ),
.g_resetn        (g_resetn          ),
.cpu_ack         (cpu_dmem_ack      ),
.periph_req      (ram_dmem_req      ),
.periph_ack      (ram_dmem_ack      ),
.periph_recv     (ram_dmem_recv     ),
.periph_gnt      (ram_dmem_gnt      ),
.route_periph_rsp(route_rsp_dmem_ram)
);

//
// Data <-> ROM Routing
// ------------------------------------------------------------

assign rom_dmem_req   = ic_dmem_route_rom && cpu_dmem_req;

assign rom_dmem_wen   = cpu_dmem_wen  ; // Write enable
assign rom_dmem_strb  = cpu_dmem_strb ; // Write strobe
assign rom_dmem_wdata = cpu_dmem_wdata; // Write data
assign rom_dmem_addr  = cpu_dmem_addr ; // Read/Write address

wire   route_rsp_dmem_rom   ;

ic_rsp_router i_rsp_router_dmem_rom (
.g_clk           (g_clk             ),
.g_resetn        (g_resetn          ),
.cpu_ack         (cpu_dmem_ack      ),
.periph_req      (rom_dmem_req      ),
.periph_ack      (rom_dmem_ack      ),
.periph_recv     (rom_dmem_recv     ),
.periph_gnt      (rom_dmem_gnt      ),
.route_periph_rsp(route_rsp_dmem_rom)
);


//
// Data <-> Error Response
// ------------------------------------------------------------

wire        err_dmem_req    = ic_dmem_error && cpu_dmem_req;

wire        err_dmem_gnt    ;
wire        err_dmem_recv   ;
wire        err_dmem_ack    ;
wire        err_dmem_error  ;
wire [31:0] err_dmem_rdata  ;

wire        route_rsp_dmem_err   ;

ic_error_rsp_stub i_error_stub_dmem (
.g_clk      (g_clk          ),
.g_resetn   (g_resetn       ),
.enable     (err_dmem_req   ), // Enable requests / does addr map?
.mem_req    (err_dmem_req   ), // Start memory request
.mem_gnt    (err_dmem_gnt   ), // request accepted
.mem_wen    ( 1'b0          ), // Write enable
.mem_strb   ( 4'b0          ), // Write strobe
.mem_wdata  (32'b0          ), // Write data
.mem_addr   (32'b0          ), // Read/Write address
.mem_recv   (err_dmem_recv  ), // Instruction memory recieve response.
.mem_ack    (err_dmem_ack   ), // Instruction memory ack response.
.mem_error  (err_dmem_error ), // Error
.mem_rdata  (err_dmem_rdata )  // Read data
);

ic_rsp_router i_rsp_router_dmem_err (
.g_clk           (g_clk             ),
.g_resetn        (g_resetn          ),
.cpu_ack         (cpu_dmem_ack      ),
.periph_req      (err_dmem_req      ),
.periph_ack      (err_dmem_ack      ),
.periph_recv     (err_dmem_recv     ),
.periph_gnt      (err_dmem_gnt      ),
.route_periph_rsp(route_rsp_dmem_err)
);

//
// Instruction Response Routing
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

assign cpu_imem_gnt   = ic_imem_route_ram && ram_imem_gnt ||
                        ic_imem_route_rom && rom_imem_gnt ;

//
// Data Response Routing
// ------------------------------------------------------------

assign cpu_dmem_recv =
    route_rsp_dmem_rom  && rom_dmem_recv    ||
    route_rsp_dmem_ram  && ram_dmem_recv    ||
    route_rsp_dmem_err  && err_dmem_recv    ;

assign cpu_dmem_error=
    route_rsp_dmem_rom  && rom_dmem_error   ||
    route_rsp_dmem_ram  && ram_dmem_error   ||
    route_rsp_dmem_err  && err_dmem_error   ;

assign cpu_dmem_rdata=
    {32{route_rsp_dmem_rom}} & rom_dmem_rdata   |
    {32{route_rsp_dmem_ram}} & ram_dmem_rdata   ;

assign cpu_dmem_gnt   = ic_dmem_route_ram && ram_dmem_gnt ||
                        ic_dmem_route_rom && rom_dmem_gnt ||
                        ic_dmem_error     && err_dmem_gnt ;

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

`ifdef FORMAL_IC_TOP

initial assume(!g_resetn);

always @(posedge g_clk) if(g_resetn && $past(g_resetn)) begin

    assert(!(route_rsp_imem_ram && route_rsp_imem_rom));
    
    assert(!(route_rsp_dmem_ram && route_rsp_dmem_rom));

    if($past(cpu_imem_recv) && !$past(cpu_imem_ack)) begin
        assert($stable(cpu_imem_rdata));
        assert($stable(cpu_imem_error));
    end

    if($past(cpu_dmem_recv) && !$past(cpu_dmem_ack)) begin
        assert($stable(cpu_dmem_rdata));
        assert($stable(cpu_dmem_error));
    end

end

`endif

endmodule
