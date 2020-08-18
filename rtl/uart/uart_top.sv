
//
// module: uart_top
//
//  Top level of the UART peripheral
//
module uart_top ( 

input  wire             g_clk           , // Gated clock
output wire             g_clk_req       , // Clock request
input  wire             g_resetn        , // Global Active low sync reset.

input  wire             uart_rx         , // UART Recieve
output wire             uart_tx         , // UART Transmit

scarv_ccx_memif.RSP     memif             // Memory request interface.

);

//
// Parameters
// ------------------------------------------------------------

parameter   BIT_RATE        =    256_000; // bits / sec
parameter   CLK_HZ          = 50_000_000;
localparam  PAYLOAD_BITS    = 8         ;
parameter   STOP_BITS       = 1         ;
parameter   FIFO_DEPTH      = 8         ;


//
// Register Access
// ------------------------------------------------------------

//
// Register addresses
localparam REG_RX   = 4'h0;
localparam REG_TX   = 4'h4;
localparam REG_STAT = 4'h8;
localparam REG_CTRL = 4'hC;

//
// Which register are we accessing?
wire reg_tx         = memif.req && memif.addr[3:0] == REG_TX     ;
wire reg_rx         = memif.req && memif.addr[3:0] == REG_RX     ;
wire reg_stat       = memif.req && memif.addr[3:0] == REG_STAT   ;
wire reg_ctrl       = memif.req && memif.addr[3:0] == REG_CTRL   ;
wire reg_invalid    = !(reg_tx || reg_rx || reg_stat || reg_ctrl);

wire memif_write    = memif.req && memif.gnt &&  memif.wen;
wire memif_read     = memif.req && memif.gnt && !memif.wen;

assign        memif.gnt     = 1'b1          ;
wire        n_memif_error   = reg_invalid   || bad_tx_write;
wire [31:0] n_memif_rdata   = {24'b0,
    {8{reg_rx   }} & uart_rx_ff_data |
    {8{reg_stat }} & status_rdata    |
    {8{reg_ctrl }} & ctrl_rdata     
};

always @(posedge g_clk) begin
    if(!g_resetn) begin
        memif.rdata <= 32'b0;
    end else if(memif_read) begin
        memif.rdata <= n_memif_rdata;
    end
end

//
// MISC wiring
// ------------------------------------------------------------

wire         clk_req_rx  ;
wire         clk_req_tx  ;
wire         clk_req_rx_fifo;
wire         clk_req_tx_fifo;
assign       g_clk_req   = clk_req_rx || clk_req_tx || memif.req ||
                           clk_req_rx_fifo || clk_req_tx_fifo ;

wire        uart_rx_en   ; // Recieve enable
wire        uart_rx_break; // Did we get a BREAK message?
wire        uart_rx_valid; // Valid data recieved and available.
wire [ 7:0] uart_rx_data ; // The recieved data.

wire        uart_tx_busy ; // Module busy sending previous item.
wire        uart_tx_en   ; // Send the data on uart_tx_data
wire [ 7:0] uart_tx_data ; // The data to be sent

//
// Trivial register read/write access.
// ------------------------------------------------------------

//
// TX Register

wire        uart_tx_push = !status_tx_full && reg_tx && memif_write &&
                            memif.strb[0];

wire        bad_tx_write = reg_tx && memif_write && status_tx_full;

wire        uart_tx_ff_ready;
wire        uart_tx_ff_pop  = !uart_tx_busy;
assign      uart_tx_en      = uart_tx_ff_ready && uart_tx_ff_pop;

//
// RX Register

wire        uart_rx_ff_valid;
wire [7:0]  uart_rx_ff_data ;
wire        read_rx_fifo    = memif_read && reg_rx;

//
// STAT Register

wire        status_rx_valid = uart_rx_valid;
wire        status_tx_full  ;
wire        status_rx_full  ;
reg         status_rx_break ;
wire        clr_status_break;

wire [ 7:0] status_rdata = {
    1'b0            ,
    1'b0            ,
    1'b0            ,
    1'b0            ,
    status_tx_full  ,
    1'b0            ,
    status_rx_full  ,
    status_rx_valid
};

//
// CTRL Register

wire [7:0] ctrl_rdata = 8'b0;

//
// Submodule instances
// ------------------------------------------------------------

uart_fifo #(
.DEPTH(FIFO_DEPTH),
.WIDTH(PAYLOAD_BITS)
) i_tx_fifo (
.g_clk      (g_clk              ), // Clock
.g_clk_req  (clk_req_tx_fifo    ), // Clock request
.g_resetn   (g_resetn           ), // Reset
.full       (status_tx_full     ), // Cannot accept any more inputs.
.push       (uart_tx_push       ), // Input word valid.
.in_data    (memif.wdata[7:0]   ), // Input word data.
.out_valid  (uart_tx_ff_ready   ), // Output word valid.
.out_data   (uart_tx_data       ), // Output data word.
.pop        (uart_tx_ff_pop     )  // Extract an output word.
);

uart_fifo #(
.DEPTH(FIFO_DEPTH),
.WIDTH(PAYLOAD_BITS)
) i_rx_fifo (
.g_clk      (g_clk              ), // Clock
.g_clk_req  (clk_req_rx_fifo    ), // Clock request
.g_resetn   (g_resetn           ), // Reset
.full       (status_rx_full     ), // Cannot accept any more inputs.
.push       (uart_rx_valid      ), // Input word valid.
.in_data    (uart_rx_data       ), // Input word data.
.out_valid  (uart_rx_ff_valid   ), // Output word valid.
.out_data   (uart_rx_ff_data    ), // Output data word.
.pop        (read_rx_fifo       )  // Extract an output word.
);

uart_rx #(
.BIT_RATE       (BIT_RATE       ),
.CLK_HZ         (CLK_HZ         ),
.PAYLOAD_BITS   (PAYLOAD_BITS   ),
.STOP_BITS      (STOP_BITS      )
) i_rx (
.clk            (g_clk          ), // Top level system clock input.
.clk_req        (clk_req_rx     ), // UART RX Clock request.
.resetn         (g_resetn       ), // Asynchronous active low reset.
.uart_rxd       (uart_rx        ), // UART Recieve pin.
.uart_rx_en     (uart_rx_en     ), // Recieve enable
.uart_rx_break  (uart_rx_break  ), // Did we get a BREAK message?
.uart_rx_valid  (uart_rx_valid  ), // Valid data recieved and available.
.uart_rx_data   (uart_rx_data   )  // The recieved data.
);

uart_tx #(
.BIT_RATE       (BIT_RATE       ),
.CLK_HZ         (CLK_HZ         ),
.PAYLOAD_BITS   (PAYLOAD_BITS   ),
.STOP_BITS      (STOP_BITS      )
) i_tx (
.clk            (g_clk          ), // Top level system clock input.
.clk_req        (clk_req_tx     ), // UART TX Clock request.
.resetn         (g_resetn       ), // Asynchronous active low reset.
.uart_txd       (uart_tx        ), // UART transmit pin.
.uart_tx_busy   (uart_tx_busy   ), // Module busy sending previous item.
.uart_tx_en     (uart_tx_en     ), // Send the data on uart_tx_data
.uart_tx_data   (uart_tx_data   )  // The data to be sent
);

endmodule


