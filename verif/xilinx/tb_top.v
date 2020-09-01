`timescale 1ns / 1ps

module tb_top();

reg sys_clk_clk_n;
reg sys_clk_clk_p;
reg sys_reset      = 1'b0;

initial sys_clk_clk_n = 1'b0;
initial sys_clk_clk_p = 1'b1;

always @(sys_clk_clk_p) #10 sys_clk_clk_n <= !sys_clk_clk_n;
always @(sys_clk_clk_p) #10 sys_clk_clk_p <= !sys_clk_clk_p;

initial #100 sys_reset = 1'b1;
initial #200 sys_reset = 1'b0;

wire [8:0] gpio;

reg         uart_rxd = 1'b1;
wire        uart_txd;

sys_top_wrapper i_dut(
.diff_clk_200mhz_clk_n(sys_clk_clk_n),
.diff_clk_200mhz_clk_p(sys_clk_clk_p),
.gpio(gpio),
.reset(sys_reset),
.uart_rxd(uart_rxd),
.uart_txd(uart_txd)
);

endmodule
