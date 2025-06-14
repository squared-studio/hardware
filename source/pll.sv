// This module implements a Phase-Locked Loop (PLL).
// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2025 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module pll #(
    parameter int REF_DEV_WIDTH = 4,  // Width of the reference divider register
    parameter int FB_DIV_WIDTH  = 8   // Width of the feedback divider register
) (
    input logic                     arst_ni,    // Asynchronous reset, active low
    input logic                     clk_ref_i,  // Reference clock input
    input logic [REF_DEV_WIDTH-1:0] refdiv_i,   // Reference divider value
    input logic [ FB_DIV_WIDTH-1:0] fbdiv_i,    // Feedback divider value

    output logic clk_o,    // PLL output clock
    output logic locked_o  // Lock indicator output
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                     divided_clk_ref;  // Clock after reference divider
  logic                     divided_clk_fb;  // Clock after feedback divider
  logic                     freq_incr;  // Frequency increase signal from phase detector
  logic                     freq_decr;  // Frequency decrease signal from phase detector
  logic                     stable_cfg;  // Indicates if the divider configurations are stable
  logic [REF_DEV_WIDTH-1:0] refdiv_q;  // Registered value of the reference divider
  logic [ FB_DIV_WIDTH-1:0] fbdiv_q;  // Registered value of the feedback divider

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign stable_cfg = (refdiv_q == refdiv_i) & (fbdiv_q == fbdiv_i);  // Asserted when the divider values are stable

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS (Register Transfer Level)
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Reference clock divider instantiation
  clk_div #(
      .DIV_WIDTH(REF_DEV_WIDTH)
  ) u_ref_dev (
      .arst_ni(arst_ni),     // Asynchronous reset input
      .div_i  (refdiv_i),   // Divider value input
      .clk_i  (clk_ref_i),  // Reference clock input
      .clk_o  (divided_clk_ref) // Divided clock output
  );

  // Feedback clock divider instantiation
  clk_div #(
      .DIV_WIDTH(FB_DIV_WIDTH)
  ) u_fb_dev (
      .arst_ni(arst_ni),        // Asynchronous reset input
      .div_i  (fbdiv_i),        // Divider value input
      .clk_i  (clk_o),          // Feedback clock input
      .clk_o  (divided_clk_fb)  // Divided clock output
  );

  // Phase detector instantiation
  phase_detector u_pd (
      .arst_ni    (arst_ni),          // Asynchronous reset input
      .clk_ref_i  (divided_clk_ref),  // Reference clock input (after division)
      .clk_pll_i  (divided_clk_fb),   // PLL clock input (after division)
      .freq_incr_o(freq_incr),        // Frequency increase output
      .freq_decr_o(freq_decr)         // Frequency decrease output
  );

  // Voltage Controlled Oscillator (VCO) instantiation
  vco u_vco (
      .arst_ni    (arst_ni),     // Asynchronous reset input
      .freq_incr_i(freq_incr),   // Frequency increase input from phase detector
      .freq_decr_i(freq_decr),   // Frequency decrease input from phase detector
      .stable_cfg (stable_cfg),  // Configuration stability input
      .clk_o      (clk_o),       // PLL output clock
      .locked_o   (locked_o)     // Lock indicator output
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Register the divider values
  always_ff @(negedge clk_o or negedge arst_ni) begin  // Clocked by PLL output clock, reset by arst_ni
    if (~arst_ni) begin  // Asynchronous reset condition
      refdiv_q <= '0;  // Reset reference divider register
      fbdiv_q  <= '0;  // Reset feedback divider register
    end else begin  // Normal operation
      refdiv_q <= refdiv_i;  // Update reference divider register
      fbdiv_q  <= fbdiv_i;  // Update feedback divider register
    end
  end

endmodule
