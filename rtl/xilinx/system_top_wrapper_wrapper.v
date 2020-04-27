//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
//Date        : Mon Apr 27 16:16:24 2020
//Host        : benm-lt running 64-bit Ubuntu 18.04.4 LTS
//Command     : generate_target system_top_wrapper_wrapper.bd
//Design      : system_top_wrapper_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_top_wrapper_wrapper
   (gpio_led_tri_o,
    gpio_trig_tri_o,
    sys_clk_clk_n,
    sys_clk_clk_p,
    sys_reset,
    uart_rxd,
    uart_txd);
  output [9:0]gpio_led_tri_o;
  output [0:0]gpio_trig_tri_o;
  input sys_clk_clk_n;
  input sys_clk_clk_p;
  input sys_reset;
  input uart_rxd;
  output uart_txd;

  wire [9:0]gpio_led_tri_o;
  wire [0:0]gpio_trig_tri_o;
  wire sys_clk_clk_n;
  wire sys_clk_clk_p;
  wire sys_reset;
  wire uart_rxd;
  wire uart_txd;

  system_top_wrapper system_top_wrapper_i
       (.gpio_led_tri_o(gpio_led_tri_o),
        .gpio_trig_tri_o(gpio_trig_tri_o),
        .sys_clk_clk_n(sys_clk_clk_n),
        .sys_clk_clk_p(sys_clk_clk_p),
        .sys_reset(sys_reset),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd));
endmodule
