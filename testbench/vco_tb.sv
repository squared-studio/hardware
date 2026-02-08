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

  bit                         test_passed;

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
    int delta_int;
    bit freq_incr;
    bit freq_decr;
    realtime setup_begin;
    realtime setup_done;
    setup_begin = $realtime;
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
    setup_done = $realtime;
    $display("Reached target frequency: %0.2f (%0.2f) Hz with control voltage: %0d", current_freq,
             target_freq, voltage_ctrl_i);
    $display("Setup Started at: %0t", setup_begin);
    $display("Setup Done at: %0t", setup_done);
    $display("\033[1;33mTime taken to reach target frequency: %0t\033[0m",
             (setup_done - setup_begin));
    if ((setup_done - setup_begin) > 21us) begin
      $display("\033[1;31mSetup time exceeded 21 microseconds!\033[0m");
      test_passed = 0;
    end else begin
      $display("\033[1;32mSetup time within acceptable limits.\033[0m");
    end
    $display("\n\n");
    repeat (2) @(posedge clk_o);
  endtask

  initial begin
    test_passed = 1;
    // $dumpfile("vco_tb.vcd");
    // $dumpvars(0, vco_tb);
    $timeformat(-9, 0, " ns", 20);
    fork
      begin
        forever begin
          #1us;
          $display("Time: %0t", $realtime);
        end
      end
    join_none
    voltage_ctrl_i <= 0;
    repeat (2) @(posedge clk_o);
    repeat (100) get_frequency($urandom_range(32'd100_000, 32'd2_000_000_000));

    if (test_passed) $display("\033[1;32m************** TEST PASSED **************\033[0m");
    else $display("\033[1;31m************** TEST FAILED **************\033[0m");

    $finish;
  end

endmodule
