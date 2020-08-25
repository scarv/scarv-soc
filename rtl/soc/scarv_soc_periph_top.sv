
//
// module: scarv_soc_periph_top
//
//  Top level module containing all of the peripheral devices.
//
//  - The peripheral subsystem has a 64KB address sub-space
//
//  - Each peripheral has a 4KB address space for registers etc, meaning
//    space for 16 devices.
//
//  - The top module is responsible for selecting which device to route a
//    request to, and response from.
//
//  - The default address map is:
//
//      Peripheral  |   Base Address    |   Top Address
//      ------------|-------------------|-----------------
//      UART        | 0x????_0000       | 0x????_0FFF
//      GPIO        | 0x????_1000       | 0x????_1FFF
//
module scarv_soc_periph_top (

input  wire             f_clk           , // Free running clock.
input  wire             g_clk_uart      , // UART Clock
input  wire             g_clk_gpio      , // GPIO Clock
output wire             g_clk_req_uart  , // UART Clock request
output wire             g_clk_req_gpio  , // GPIO Clock request
input  wire             g_resetn        , // Global Active low sync reset.

input  wire             uart_rxd        , // UART Recieve
output wire             uart_txd        , // UART Transmit

inout  wire [GPION:0]   gpio            , // GPIO wires

scarv_ccx_memif.RSP     memif             // Memory requests.

);

//
// Address Map Parameters
// ------------------------------------------------------------

parameter   BASE_UART       = 32'h1000_0000;
parameter   BASE_GPIO       = 32'h1000_1000;

localparam  PERIPH_SIZE     = 32'h0FFF;

//
// Peripheral Parameters
// ------------------------------------------------------------

//! Number of GPIO pins.
parameter  PERIPH_GPIO_NUM = 16;
localparam GPION           = PERIPH_GPIO_NUM - 1;

parameter   UART_BIT_RATE  =    256_000; // bits / sec
parameter   UART_CLK_HZ    = 50_000_000;
parameter   UART_STOP_BITS = 1         ;

//
// Peripheral device selection
// ------------------------------------------------------------

scarv_ccx_memif #(.AW(32)) memif_uart (); // UART memory interface.
scarv_ccx_memif #(.AW(32)) memif_gpio (); // GPIO memory interface.
scarv_ccx_memif #(.AW(32)) memif_null0(); // spare memory interface.
scarv_ccx_memif #(.AW(32)) memif_null1(); // spare memory interface.

//
// Requestor to device router. Re-used from the scarv-cpu core complex.
scarv_ccx_ic_router #(
.AW         (          32),
.DW         (          32),
.NDEVICES   (           2),
.D0_BASE    (   BASE_UART),
.D0_SIZE    ( PERIPH_SIZE),
.D1_BASE    (   BASE_GPIO),
.D1_SIZE    ( PERIPH_SIZE),
.D2_BASE    (32'hFFFFFFFF),
.D2_SIZE    ( PERIPH_SIZE),
.D3_BASE    (32'hFFFFFFFF),
.D3_SIZE    ( PERIPH_SIZE)
)i_periph_router (
.g_clk      (f_clk          ),
.g_resetn   (g_resetn       ),
.if_core    (memif          ), // CPU requestor
.if_d0      (memif_uart     ),
.if_d1      (memif_gpio     ),
.if_d2      (memif_null0    ),
.if_d3      (memif_null1    )
);

//
// Peripheral device instantiation
// ------------------------------------------------------------

//
// instance: uart_top
//
//  Top level of the UART peripheral
//
uart_top #(
.BIT_RATE  (UART_BIT_RATE  ),
.CLK_HZ    (UART_CLK_HZ    ),
.STOP_BITS (UART_STOP_BITS )
) i_uart ( 
.g_clk      (g_clk_uart     ), // Gated clock
.g_clk_req  (g_clk_req_uart ), // Clock request
.g_resetn   (g_resetn       ), // Global Active low sync reset.
.uart_rxd   (uart_rxd       ), // UART Recieve
.uart_txd   (uart_txd       ), // UART Transmit
.memif      (memif_uart     )  // Memory request interface.
);


//
// instance: gpio_top
//
//  Top level of the GPIO peripheral
//
gpio_top #(
.PERIPH_GPIO_NUM    (PERIPH_GPIO_NUM    )
) i_gpio( 
.g_clk      (g_clk_gpio     ), // Gated clock
.g_clk_req  (g_clk_req_gpio ), // Clock request
.g_resetn   (g_resetn       ), // Global Active low sync reset.
.gpio       (gpio           ), // GPIO wires
.memif      (memif_gpio     )  // Memory request interface.
);

endmodule

