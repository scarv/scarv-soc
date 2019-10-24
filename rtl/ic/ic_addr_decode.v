
// 
// module: ic_addr_decode
// 
//  Decodes the request addresses and signals which peripheral they
//  should be routed too.
//
//  - Request that the address is decoded by asserted req_valid
//  - One of the route_* or req_dec_err is then asserted in the same
//    cycle.
// 
module ic_addr_decode (

input  wire        g_clk        ,   // Global clock
input  wire        g_resetn     ,   // Synchronous active low reset

input  wire        req_valid    ,   // Request is valid
input  wire [31:0] req_addr     ,   // Request address

output wire        req_dec_err  ,   // Address decode error - doesn't map

output wire        route_rom    ,   // Route to the ROM
output wire        route_ram    ,   // Route to the RAM
output wire        route_axi        // Route to the AXI bridge.

);

//
// Memory map parameters

parameter MAP_ROM_MATCH = 32'h1000_0000;
parameter MAP_ROM_MASK  = 32'hFFFF_FC00;
parameter MAP_ROM_RANGE = 32'h0000_03FF;

parameter MAP_RAM_MATCH = 32'h2000_0000;
parameter MAP_RAM_MASK  = 32'hFFFF_0000;
parameter MAP_RAM_RANGE = 32'h0000_FFFF;

parameter MAP_AXI_MATCH = 32'h4000_0000;
parameter MAP_AXI_MASK  = 32'hF000_0000;
parameter MAP_AXI_RANGE = 32'h0FFF_FFFF;

//
// Where does the request map too?

wire match_rom = ((req_addr &  MAP_ROM_MASK) == (           MAP_ROM_MATCH)) &&
                 ((req_addr & ~MAP_ROM_MASK) == (req_addr & MAP_ROM_RANGE)) ;

wire match_ram = ((req_addr &  MAP_RAM_MASK) == (           MAP_RAM_MATCH)) &&
                 ((req_addr & ~MAP_RAM_MASK) == (req_addr & MAP_RAM_RANGE)) ;

wire match_axi = ((req_addr &  MAP_AXI_MASK) == (           MAP_AXI_MATCH)) &&
                 ((req_addr & ~MAP_AXI_MASK) == (req_addr & MAP_AXI_RANGE)) ;

//
// Assert route/error signals.

assign route_rom    = match_rom && req_valid;

assign route_ram    = match_ram && req_valid;

assign route_axi    = match_axi && req_valid;

assign req_dec_err  = !(match_rom || match_ram || match_axi) && req_valid;

//
// Formal checkers.

`ifdef FORMAL_IC_ADDR_DECODE

initial assume(!g_resetn);

always @(posedge g_clk) if(g_resetn && $stable(g_resetn)) begin

    assert(!(route_rom && route_ram));
    
    assert(!(route_rom && route_axi));
    
    assert(!(route_ram && route_axi));

    cover(route_rom);

    cover(route_ram);
    
    cover(route_axi);

end

`endif

endmodule
