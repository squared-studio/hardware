// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2026 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module phase_detector (
    input logic arst_ni,    // Asynchronous reset, active low
    input logic clk_ref_i,  // Reference clock input
    input logic clk_pll_i,  // PLL clock input

    output logic freq_incr_o,  // Output signal indicating frequency increase needed
    output logic freq_decr_o   // Output signal indicating frequency decrease needed
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic clk_ref_q;
  logic clk_pll_q;
  logic clk_ref_qn;
  logic clk_pll_qn;
  logic comb_arst_ni;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-COMBINATIONALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb comb_arst_ni = arst_ni & (clk_ref_qn | clk_pll_qn);

  always_comb freq_incr_o = clk_ref_q & clk_pll_qn;

  always_comb freq_decr_o = clk_pll_q & clk_ref_qn;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_ref_i or negedge comb_arst_ni) begin
    if (~comb_arst_ni) begin
      clk_ref_q  <= '0;
      clk_ref_qn <= '1;
    end else begin
      clk_ref_q  <= '1;
      clk_ref_qn <= '0;
    end
  end

  always_ff @(posedge clk_pll_i or negedge comb_arst_ni) begin
    if (~comb_arst_ni) begin
      clk_pll_q  <= '0;
      clk_pll_qn <= '1;
    end else begin
      clk_pll_q  <= '1;
      clk_pll_qn <= '0;
    end
  end

endmodule
