`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2019 09:48:06
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top();

reg sys_clk_clk_n;
reg sys_clk_clk_p;
reg sys_reset      = 1'b0;

initial sys_clk_clk_n = 1'b0;
initial sys_clk_clk_p = 1'b1;

always @(sys_clk_clk_p) #10 sys_clk_clk_n <= !sys_clk_clk_n;
always @(sys_clk_clk_p) #10 sys_clk_clk_p <= !sys_clk_clk_p;

initial #40 sys_reset = 1'b1;
initial #80 sys_reset = 1'b0;
initial #8000 sys_reset = 1'b1;
initial #8500 sys_reset = 1'b0;

wire [9:0] gpio_led_tri_o;
wire [0:0] gpio_trig_tri_o;

reg         uart_rxd = 1'b1;
wire        uart_txd;

system_top_wrapper i_dut(
.sys_clk_clk_n(sys_clk_clk_n),
.sys_clk_clk_p(sys_clk_clk_p),
.gpio_led_tri_o(gpio_led_tri_o),
.gpio_trig_tri_o(gpio_trig_tri_o),
.sys_reset(sys_reset),
.uart_rxd(uart_rxd),
.uart_txd(uart_txd)
);

endmodule
