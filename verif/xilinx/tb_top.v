`timescale 1ps / 1ps

module tb_top();

parameter   CLK_HZ          =   200_000_000;                           
localparam  CLK_P           = 1_000_000_000 /CLK_HZ; // nanoseconds 

localparam BIT_RATE = 115200;
localparam BIT_P    = 1000*(1_000_000_000 /BIT_RATE);


reg sys_clk_clk_n;
reg sys_clk_clk_p;
reg sys_reset      = 1'b0;

initial sys_clk_clk_n = 1'b0;
initial sys_clk_clk_p = 1'b1;

always @(sys_clk_clk_p) #(2500) sys_clk_clk_n <= !sys_clk_clk_n;
always @(sys_clk_clk_p) #(2500) sys_clk_clk_p <= !sys_clk_clk_p;

initial #100000 sys_reset = 1'b1;
initial #200000 sys_reset = 1'b0;

reg         uart_rxd;
wire        uart_txd;

//
// Sends a single byte down the UART line.
task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d at time %d", to_send, $time);

        #BIT_P uart_rxd = 1'b0;
        #BIT_P uart_rxd = to_send[0];
        #BIT_P uart_rxd = to_send[1];
        #BIT_P uart_rxd = to_send[2];
        #BIT_P uart_rxd = to_send[3];
        #BIT_P uart_rxd = to_send[4];
        #BIT_P uart_rxd = to_send[5];
        #BIT_P uart_rxd = to_send[6];
        #BIT_P uart_rxd = to_send[7];
        #BIT_P uart_rxd = 1'b1;
        
    end
endtask

wire [8:0] gpio;
reg [7:0] data;

initial begin
#BIT_P;
    uart_rxd=1'b1;
    send_byte(8'h53);
    send_byte(8'h00);
    send_byte(8'h00);
    send_byte(8'h00);
    send_byte(8'h00);
    send_byte(8'h00);
    send_byte(8'h01);
    send_byte(8'h00);
    for(data = 0; data < 255; data = data+1) begin
        #1 send_byte(data);
    end
end

sys_top_wrapper i_dut(
.diff_clk_200mhz_clk_n(sys_clk_clk_n),
.diff_clk_200mhz_clk_p(sys_clk_clk_p),
.gpio(gpio),
.reset(sys_reset),
.uart_rxd(uart_rxd),
.uart_txd(uart_txd)
);

endmodule
