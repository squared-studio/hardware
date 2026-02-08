// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2026 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

// `define USE_RTL_BASED_PLL_MODEL 0

// MINIMUM FREQUENCY = 1 MHz
// MAXIMUM FREQUENCY = 10 GHz

module pll #(
    parameter int REF_DEV_WIDTH = 4,
    parameter int FB_DIV_WIDTH  = 8
) (
    input  logic                     arst_ni,
    input  logic                     clk_ref_i,
    input  logic [REF_DEV_WIDTH-1:0] ref_div_i,
    input  logic [ FB_DIV_WIDTH-1:0] fb_div_i,
    output logic                     clk_o,
    output logic                     locked_o
);

`ifdef USE_RTL_BASED_PLL_MODEL

  localparam int VcoRes = 25;

  logic [REF_DEV_WIDTH-1:0] sampled_refdiv;
  logic [FB_DIV_WIDTH-1:0] sampled_fbdiv;

  logic divided_ref_clk;
  logic divided_vco_clk;

  logic [VcoRes:0] voltage_ctrl;
  logic [VcoRes:0] voltage_ctrl_next;
  logic [VcoRes:0] delta_voltage;

  logic clk_vco;

  logic freq_incr;
  logic freq_decr;

  logic [31:0] stable_count;

  assign voltage_ctrl_next = voltage_ctrl + delta_voltage;

  assign clk_o = clk_vco;

  assign locked_o = (stable_count >= 'h8_0000);

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
      .MIN_FREQ_HZ    (1E6),
      .MAX_FREQ_HZ    (10E9),
      .RESOLUTION_BITS(VcoRes)
  ) u_vco (
      .voltage_ctrl_i(voltage_ctrl[VcoRes-1:0]),
      .clk_o(clk_vco)
  );

  always_ff @(posedge clk_ref_i or negedge arst_ni) begin
    if (~arst_ni) begin
      sampled_refdiv <= 0;
    end else begin
      sampled_refdiv <= ref_div_i;
    end
  end

  always_ff @(posedge clk_ref_i or negedge arst_ni) begin
    if (~arst_ni) begin
      sampled_fbdiv <= 0;
    end else begin
      sampled_fbdiv <= fb_div_i;
    end
  end

  always #1ps begin
    if (~arst_ni) begin
      delta_voltage <= '0;
      voltage_ctrl  <= '0;
      stable_count  <= '0;
    end else begin
      if (delta_voltage[VcoRes] == 0) begin
        if (freq_incr) begin
          if (signed'(delta_voltage) < 128) delta_voltage <= delta_voltage + 1;
        end else if (freq_decr) begin
          delta_voltage <= -1;
        end else begin
          delta_voltage <= '0;
        end
      end else begin
        if (freq_decr) begin
          if (signed'(delta_voltage) > -128) delta_voltage <= delta_voltage - 1;
        end else if (freq_incr) begin
          delta_voltage <= 1;
        end else begin
          delta_voltage <= '0;
        end
      end
      if (voltage_ctrl_next[VcoRes]) begin
        voltage_ctrl  <= voltage_ctrl;
        delta_voltage <= '0;
      end else begin
        voltage_ctrl <= voltage_ctrl + delta_voltage;
      end
      if (signed'(delta_voltage) > -10 && signed'(delta_voltage) < 10) begin
        if (stable_count < 'hF_FFFF) stable_count <= stable_count + 1;
      end else begin
        stable_count <= '0;
      end
    end
  end

`else

  logic    [REF_DEV_WIDTH-1:0] refdiv_q;
  logic    [ FB_DIV_WIDTH-1:0] fbdiv_q;

  logic                        stable;

  realtime                     ref_clk_tick = 0;
  realtime                     half_timeperiod = 500ns;

  logic                        internal_lock;
  logic    [             15:0] lock_array;

  always_ff @(posedge clk_ref_i or negedge arst_ni) begin
    if (~arst_ni) begin
      refdiv_q <= '0;
      fbdiv_q  <= '0;
    end else begin
      refdiv_q <= ref_div_i;
      fbdiv_q  <= fb_div_i;
    end
  end

  always_comb stable = arst_ni & (refdiv_q == ref_div_i) & (fbdiv_q == fb_div_i);

  always_ff @(posedge clk_o or negedge stable) begin
    if (~stable) begin
      lock_array <= '0;
    end else begin
      lock_array <= {lock_array[14:0], internal_lock};
    end
  end

  always_comb locked_o = lock_array[15];

  always @(clk_ref_i or negedge arst_ni) begin
    if (~arst_ni) begin
      half_timeperiod = 500ns;
      internal_lock   = '0;
    end else begin
      realtime target_half_timeperiod;
      target_half_timeperiod = $realtime - ref_clk_tick;
      if (ref_div_i) target_half_timeperiod = target_half_timeperiod * unsigned'(ref_div_i);
      if (fb_div_i) target_half_timeperiod = target_half_timeperiod / unsigned'(fb_div_i);
      if (target_half_timeperiod > 500ns) target_half_timeperiod = 500ns;
      if (target_half_timeperiod < 50ps) target_half_timeperiod = 50ps;
      if (half_timeperiod < target_half_timeperiod)
        half_timeperiod = half_timeperiod * 0.97 + 0.03 * target_half_timeperiod + 1ps;
      else half_timeperiod = half_timeperiod * 0.97 + 0.03 * target_half_timeperiod - 1ps;
      if (((half_timeperiod - target_half_timeperiod) > -10ps) && ((half_timeperiod - target_half_timeperiod) < 10ps))
        internal_lock = '1;
      else internal_lock = '0;
    end
    ref_clk_tick = $realtime;
  end

  initial begin
    clk_o <= '0;
    forever begin
      if (arst_ni) clk_o <= '1;
      #(half_timeperiod);
      clk_o <= '0;
      #(half_timeperiod);
    end
  end

`endif

endmodule
