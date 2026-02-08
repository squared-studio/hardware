// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2026 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module vco_tb;

  parameter real MIN_FREQ_HZ = 100E3;
  parameter real MAX_FREQ_HZ = 10E9;
  parameter int RESOLUTION_BITS = 30;

  logic [RESOLUTION_BITS-1:0] voltage_ctrl_i;
  logic                       clk_o;

  vco #(
      .MIN_FREQ_HZ    (MIN_FREQ_HZ),
      .MAX_FREQ_HZ    (MAX_FREQ_HZ),
      .RESOLUTION_BITS(RESOLUTION_BITS)
  ) u_vco (
      .voltage_ctrl_i(voltage_ctrl_i),
      .clk_o(clk_o)
  );

  realtime this_cycle = 1s / MIN_FREQ_HZ;
  realtime last_tick = 0;
  real current_freq;

  always @(posedge clk_o) begin
    this_cycle = $realtime - last_tick;
    last_tick = $realtime;
    current_freq = 1000ms / this_cycle;
  end

  task static get_frequency(input real target_freq);
    real delta;
    int  delta_int;
    bit  freq_incr;
    bit  freq_decr;
    do begin
      if (current_freq < target_freq) begin
        delta = target_freq - current_freq;
        if (delta < 0) $display("Delta negative!");
        delta_int = delta;
        if (voltage_ctrl_i != '1)
          if ((voltage_ctrl_i + (1 + delta_int / 25)) > voltage_ctrl_i)
            voltage_ctrl_i <= voltage_ctrl_i + (1 + delta_int / 25);
          else voltage_ctrl_i <= '1;
        freq_incr = 1;
        freq_decr = 0;
      end else if (current_freq > target_freq) begin
        delta = current_freq - target_freq;
        if (delta < 0) $display("Delta negative!");
        delta_int = delta;
        if (voltage_ctrl_i != '0)
          if ((voltage_ctrl_i - (1 + delta_int / 25)) < voltage_ctrl_i)
            voltage_ctrl_i <= voltage_ctrl_i - (1 + delta_int / 25);
          else voltage_ctrl_i <= '0;
        freq_decr = 1;
        freq_incr = 0;
      end else begin
        delta = 0;
        freq_incr = 0;
        freq_decr = 0;
      end
      @(posedge clk_o);
    end while ((delta * 1000) > target_freq);
    $display("Reached target frequency: %0.2f (%0.2f) Hz with control voltage: %0d", current_freq,
             target_freq, voltage_ctrl_i);
    repeat (20) @(posedge clk_o);
  endtask

  initial begin
    // $dumpfile("vco_tb.vcd");
    // $dumpvars(0, vco_tb);
    fork
      begin
        int i;
        forever begin
          #1us;
          i++;
          $display("Time: %0d us", i);
        end
      end
      // begin
      //   #250us;
      //   $display("Timeout reached");
      //   $finish;
      // end
    join_none
    voltage_ctrl_i <= 0;
    repeat (2) @(posedge clk_o);
    repeat (100) get_frequency($urandom_range(32'd100_000, 32'd2_000_000_000));
    $finish;
  end

endmodule
