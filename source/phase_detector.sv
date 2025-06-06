// Write a markdown documentation for this systemverilog module:
// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2025 squared-studio
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

  logic clk_ref_posedge;  // Internal signal to detect positive edge of reference clock
  logic clk_ref_negedge;  // Internal signal to detect negative edge of reference clock
  logic clk_pll_posedge;  // Internal signal to detect positive edge of PLL clock
  logic clk_pll_negedge;  // Internal signal to detect negative edge of PLL clock
  logic comb_arst_ni;  // Combinational asynchronous reset signal

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // This assignment creates a combinational reset signal.  It's active low.
  // The reset is asserted if arst_ni is low OR if both clocks (ref & pll) have a simultaneous edge (positive or negative)
  // This is done to prevent metastability issues during simultaneous clock transitions near reset.
  always_comb
    comb_arst_ni = arst_ni & (~(
                                (clk_ref_posedge & clk_pll_posedge) |
                                (clk_ref_negedge & clk_pll_negedge)
                              ));

  // If reference clock has a posedge or negedge.
  always_comb freq_incr_o = clk_ref_posedge | clk_ref_negedge;

  // If PLL clock has a posedge or negedge.
  always_comb freq_decr_o = clk_pll_posedge | clk_pll_negedge;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Macro definition to generate flip-flops to detect clock edges
  `define PHASE_DETECTOR_FLIPFLOP_GENENRATOR(__CLK__, __EDGE__)                 \
  always_ff @(``__EDGE__``edge clk_``__CLK__``_i or negedge comb_arst_ni) begin \
    if (~comb_arst_ni) begin                                                    \
      clk_``__CLK__``_``__EDGE__``edge <= '0;                                   \
    end else begin                                                              \
      clk_``__CLK__``_``__EDGE__``edge <= '1;                                   \
    end                                                                         \
  end                                                                           \

  // Instantiate flip-flops for rising and falling edges of reference clock
  `PHASE_DETECTOR_FLIPFLOP_GENENRATOR(ref, pos)

  // Instantiate flip-flops for falling edges of reference clock
  `PHASE_DETECTOR_FLIPFLOP_GENENRATOR(ref, neg)

  // Instantiate flip-flops for rising edges of PLL clock
  `PHASE_DETECTOR_FLIPFLOP_GENENRATOR(pll, pos)

  // Instantiate flip-flops for falling edges of PLL clock
  `PHASE_DETECTOR_FLIPFLOP_GENENRATOR(pll, neg)

  // Undefine the macro
  `undef PHASE_DETECTOR_FLIPFLOP_GENENRATOR

endmodule
