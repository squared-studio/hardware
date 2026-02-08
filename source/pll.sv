// Write a markdown documentation for this systemverilog module:
// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2026 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module pll #(
    parameter int REF_DEV_WIDTH = 4,
    parameter int FB_DIV_WIDTH  = 8
) (
    input  logic                     arst_ni,
    input  logic                     clk_ref_i,
    input  logic [REF_DEV_WIDTH-1:0] refdiv_i,
    input  logic [ FB_DIV_WIDTH-1:0] fbdiv_i,
    output logic                     clk_o,
    output logic                     locked_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [REF_DEV_WIDTH-1:0] sampled_refdiv;  // Sampled reference divider
  logic [FB_DIV_WIDTH-1:0] sampled_fbdiv;  // Sampled feedback divider

  logic divided_ref_clk;  // Divided reference clock
  logic divided_vco_clk;  // Divided VCO clock

  logic [19:0] voltage_ctrl;  // Control voltage input for VCO

  logic clk_vco;  // Clock output from VCO

  logic freq_incr;  // Frequency increase signal from phase detector
  logic freq_decr;  // Frequency decrease signal from phase detector

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  clk_div #(
      .DIV_WIDTH(REF_DEV_WIDTH)
  ) u_ref_div (
      .arst_ni(arst_ni),
      .clk_i  (clk_ref_i),
      .div_i  (sampled_refdiv),
      .clk_o  (divided_ref_clk)
  );

  clk_div #(
      .DIV_WIDTH(FB_DIV_WIDTH)
  ) u_vco_div (
      .arst_ni(arst_ni),
      .clk_i  (clk_vco),
      .div_i  (sampled_fbdiv),
      .clk_o  (divided_vco_clk)
  );

  phase_detector u_pd (
      .arst_ni(arst_ni),
      .clk_ref_i(divided_ref_clk),
      .clk_pll_i(divided_vco_clk),
      .freq_incr_o(freq_incr),
      .freq_decr_o(freq_decr)
  );

  vco #(
      .MIN_FREQ_HZ    (100E3),
      .MAX_FREQ_HZ    (10E9),
      .RESOLUTION_BITS(20)
  ) u_vco (
      .voltage_ctrl_i(voltage_ctrl),
      .clk_o(clk_vco)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_ref_i or negedge arst_ni) begin
    if (~arst_ni) begin
      sampled_refdiv <= 0;
    end else begin
      sampled_refdiv <= refdiv_i;
    end
  end

  always_ff @(posedge clk_ref_i or negedge arst_ni) begin
    if (~arst_ni) begin
      sampled_fbdiv <= 0;
    end else begin
      sampled_fbdiv <= fbdiv_i;
    end
  end

  always #10ps begin
    if (~arst_ni) begin
      voltage_ctrl <= '0;
    end else begin
      voltage_ctrl <= voltage_ctrl;
      case ({
        freq_incr, freq_decr
      })
        2'b01:   if (voltage_ctrl != 20'h0_0000) voltage_ctrl <= voltage_ctrl - 1;
        2'b10:   if (voltage_ctrl != 20'hF_FFFF) voltage_ctrl <= voltage_ctrl + 1;
        default: voltage_ctrl <= voltage_ctrl;
      endcase
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
