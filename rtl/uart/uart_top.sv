
//
// module: uart_top
//
//  Top level of the UART peripheral
//
module uart_top ( 

input  wire             g_clk           , // Gated clock
output wire             g_clk_req       , // Clock request
input  wire             g_resetn        , // Global Active low sync reset.

output wire             interrupt       , // UART raising an interrupt.

input  wire             uart_rxd        , // UART Recieve
output wire             uart_txd        , // UART Transmit

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
        memif.error <= 1'b0;
    end else if(memif_read) begin
        memif.rdata <= n_memif_rdata;
        memif.error <= n_memif_error;
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

wire        status_rx_valid = uart_rx_ff_valid;
wire        status_tx_full  ;
wire        status_rx_full  ;
wire        status_rx_busy  ;
wire        clr_status_break;

reg         status_rx_break ;
reg         status_int      ;

wire        n_status_rx_break =
    ctrl_clear_break ? 1'b0 : status_rx_break || uart_rx_break;

wire        n_status_int    =
    ctrl_clear_int   ? 1'b0 :
        ctrl_en_int_break   && uart_rx_break    ||
        ctrl_en_int_rx_any  && status_rx_valid  ||
        ctrl_en_int_rx_full && status_rx_full    ;

assign      interrupt       = status_int;

wire [ 7:0] status_rdata = {
    1'b0            ,
    status_int      ,
    uart_tx_busy    ,
    status_tx_full  ,
    status_rx_break ,
    status_rx_busy  ,
    status_rx_full  ,
    status_rx_valid
};

always @(posedge g_clk) begin
    if(!g_resetn) begin
        status_rx_break <= 1'b0;
        status_int      <= 1'b0;
    end else begin
        status_rx_break <= n_status_rx_break;
        status_int      <= n_status_int     ;
    end
end

//
// CTRL Register

// Clear RX FIFO on writing a 1.
wire ctrl_clear_rx      = reg_ctrl && memif_write && memif.wdata[6];

// Clear TX FIFO on writing a 1.
wire ctrl_clear_tx      = reg_ctrl && memif_write && memif.wdata[5];

// Clear Break indicator bit.
wire ctrl_clear_break   = reg_ctrl && memif_write && memif.wdata[4];

// Clear interrupt bit.
wire ctrl_clear_int     = reg_ctrl && memif_write && memif.wdata[3];

reg  ctrl_en_int_break  ; // Enable interrupt on recieving break.
reg  ctrl_en_int_rx_any ; // Enable interrupt on any RX.
reg  ctrl_en_int_rx_full; // Enable interrupt on RX FIFO full.

wire [7:0] ctrl_rdata = {
    1'b0                , // 7
    ctrl_clear_rx       , // 6
    ctrl_clear_tx       , // 5
    ctrl_clear_break    , // 4
    ctrl_clear_int      , // 3
    ctrl_en_int_break   , // 2
    ctrl_en_int_rx_any  , // 1
    ctrl_en_int_rx_full   // 0
};

always @(posedge g_clk) begin
    if(!g_resetn) begin
        ctrl_en_int_break   <= 1'b0;
        ctrl_en_int_rx_any  <= 1'b0;
        ctrl_en_int_rx_full <= 1'b0;
    end else if(reg_ctrl && memif_write) begin
        ctrl_en_int_break   <= memif.wdata[2];
        ctrl_en_int_rx_any  <= memif.wdata[1];
        ctrl_en_int_rx_full <= memif.wdata[0];
    end
end

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
.clear      (ctrl_clear_tx      ), // Clear the FIFO
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
.clear      (ctrl_clear_rx      ), // Clear the FIFO
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
.uart_rxd       (uart_rxd       ), // UART Recieve pin.
.uart_rx_en     (!status_rx_full), // Recieve enable
.uart_rx_break  (uart_rx_break  ), // Did we get a BREAK message?
.uart_rx_valid  (uart_rx_valid  ), // Valid data recieved and available.
.uart_rx_busy   (status_rx_busy ), // Are we recieving something?
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
.uart_txd       (uart_txd       ), // UART transmit pin.
.uart_tx_busy   (uart_tx_busy   ), // Module busy sending previous item.
.uart_tx_en     (uart_tx_en     ), // Send the data on uart_tx_data
.uart_tx_data   (uart_tx_data   )  // The data to be sent
);

endmodule


