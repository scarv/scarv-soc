//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
//Date        : Mon Sep  7 10:19:01 2020
//Host        : benm-lt running 64-bit Ubuntu 18.04.5 LTS
//Command     : generate_target sys_top_wrapper.bd
//Design      : sys_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module sys_top_wrapper
   (diff_clk_200mhz_clk_n,
    diff_clk_200mhz_clk_p,
    gpio,
    reset,
    uart_rxd,
    uart_txd);
  input diff_clk_200mhz_clk_n;
  input diff_clk_200mhz_clk_p;
  inout [8:0]gpio;
  input reset;
  input uart_rxd;
  output uart_txd;

  wire diff_clk_200mhz_clk_n;
  wire diff_clk_200mhz_clk_p;
  wire [8:0]gpio;
  wire reset;
  wire uart_rxd;
  wire uart_txd;

  sys_top sys_top_i
       (.diff_clk_200mhz_clk_n(diff_clk_200mhz_clk_n),
        .diff_clk_200mhz_clk_p(diff_clk_200mhz_clk_p),
        .gpio(gpio),
        .reset(reset),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd));
endmodule
