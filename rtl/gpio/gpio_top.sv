
//
// module: gpio_top
//
//  Top level of the GPIO peripheral
//
module gpio_top ( 

input  wire          g_clk           , // Gated clock
output wire          g_clk_req       , // Clock request
input  wire          g_resetn        , // Global Active low sync reset.

output wire [NP:0]   gpio_io         , // GPIO wire direction. 1=in, 0=out.
output wire [NP:0]   gpio_out        , // GPIO outputs.
input  wire [NP:0]   gpio_in         , // GPIO inputs.

scarv_ccx_memif.RSP  memif             // Memory request interface.

);

//! Number of GPIO pins. Maximum of 32.
parameter  PERIPH_GPIO_NUM  = 16;
localparam NP               = PERIPH_GPIO_NUM - 1;

parameter  RESET_OUTPUTS    = 0;
parameter  RESET_DIRECTION  = 0;
parameter  RESET_CTRL       = 0;

localparam ADDR_INPUTS      = 4'h0;
localparam ADDR_OUTPUTS     = 4'h4;
localparam ADDR_DIRECTION   = 4'h8;
localparam ADDR_CTRL        = 4'hC;

//
// Memory bus interfacing
// ------------------------------------------------------------


assign memif.gnt            = 1'b1;
assign memif.error          = 1'b0;

wire   memif_read           = memif.req && memif.gnt && !memif.wen;
wire   memif_write          = memif.req && memif.gnt &&  memif.wen;

wire   memif_addr_inputs    = memif.req && memif.addr[3:0] == ADDR_INPUTS   ;
wire   memif_addr_outputs   = memif.req && memif.addr[3:0] == ADDR_OUTPUTS  ;
wire   memif_addr_direction = memif.req && memif.addr[3:0] == ADDR_DIRECTION;
wire   memif_addr_ctrl      = memif.req && memif.addr[3:0] == ADDR_CTRL     ;

generate if(PERIPH_GPIO_NUM == 32)  begin
    
    assign memif.rdata      =
        {32{memif_addr_direction}}  & reg_dir       |
        {32{memif_addr_outputs  }}  & reg_outputs   |
        {32{memif_addr_inputs   }}  & reg_inputs    |
        {32{memif_addr_ctrl     }}  & reg_ctrl      ;

end else begin

    wire [31-PERIPH_GPIO_NUM:0] padding = 'b0;
    
    assign memif.rdata      =
        {32{memif_addr_direction}}  & {padding, reg_dir     } |
        {32{memif_addr_outputs  }}  & {padding, reg_outputs } |
        {32{memif_addr_inputs   }}  & {padding, reg_inputs  } |
        {32{memif_addr_ctrl     }}  & {padding, reg_ctrl    } ;

end endgenerate

//
// GPIO Direction Register
// ------------------------------------------------------------

reg [NP:0] reg_dir          ;

wire       reg_dir_wen      = memif_write && memif_addr_direction;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_dir <= RESET_DIRECTION;
    end else if(reg_dir_wen) begin
        reg_dir <= memif.wdata[NP:0];
    end
end

//
// GPIO Input bits
// ------------------------------------------------------------

reg [NP:0] reg_inputs_buf   ; // Double-buffered GPIO inputs.
reg [NP:0] reg_inputs       ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
    end else begin
        reg_inputs_buf <= gpio_in;
        reg_inputs     <= reg_inputs_buf & ~reg_dir;
    end
end

//
// GPIO Output bits
// ------------------------------------------------------------

reg [NP:0] reg_outputs      ;
wire       reg_outputs_wen  = memif_write && memif_addr_outputs;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_outputs <= RESET_OUTPUTS;
    end else if(reg_dir_wen) begin
        reg_outputs <= memif.wdata[NP:0] & reg_outputs;
    end else if(reg_outputs_wen) begin
        reg_outputs <= memif.wdata[NP:0] & reg_dir;
    end
end


//
// GPIO Control Register
// ------------------------------------------------------------

reg [NP:0] reg_ctrl         ;

wire       reg_ctrl_wen     = memif_write && memif_addr_ctrl;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_ctrl <= RESET_CTRL;
    end else if(reg_ctrl_wen) begin
        reg_ctrl <= memif.wdata[NP:0];
    end
end

endmodule


