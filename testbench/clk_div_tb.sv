// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2026 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module clk_div_tb;

  initial $display("\033[7;38m************** TEST STARTED **************\033[0m");
  final $display("\033[7;38m*************** TEST ENDED ***************\033[0m");

  parameter int DIV_WIDTH = 4;

  parameter realtime TP = 10ns;

  parameter int SAMPLE_CYCLES = 5;

  logic                 arst_ni;
  logic [DIV_WIDTH-1:0] div_i;
  logic                 clk_i;
  logic                 clk_o;

  bit                   test_passed;

  int                   clk_o_count;

  covergroup div_coverage @(posedge clk_i iff arst_ni);
    div_cp: coverpoint div_i {bins div_bins[] = {[0 : $]};}
  endgroup

  div_coverage u_div_cov = new();

  clk_div #(
      .DIV_WIDTH(DIV_WIDTH)
  ) u_dut (
      .arst_ni,
      .div_i,
      .clk_i,
      .clk_o
  );

  task static start_clock(input realtime timeperiod = 10ns);
    fork
      forever begin
        clk_i <= '1;
        #(timeperiod / 2);
        clk_i <= '0;
        #(timeperiod / 2);
      end
    join_none
  endtask

  task static apply_reset(input realtime duration = 100ns);
    #(duration / 10);
    arst_ni <= '0;
    div_i   <= '0;
    clk_i   <= '0;
    #(duration);
    arst_ni <= '1;
    #(duration / 10);
  endtask

  wire ref_clk = clk_i;
  bit  ref_clk_error;

  specify
    $width(posedge ref_clk, (TP / 2), 0, ref_clk_error);
    $width(negedge ref_clk, (TP / 2), 0, ref_clk_error);
  endspecify
  always @(ref_clk_error) begin
    test_passed = 0;
  end

  always @(clk_o) begin
    clk_o_count++;
  end

  initial begin
    int debug;
    if (!$value$plusargs("DEBUG=%d", debug)) begin
      $fatal(1, "\033[1;31mNO DEBUG FLAG PROVIDED!\033[0m");
    end
    if (debug) begin
      $dumpfile("clk_div_tb.vcd");
      $dumpvars(0, clk_div_tb);
    end else begin
      $display("\033[1;33mDEBUG MODE DISABLED. TO ENABLE, RUN WITH DEBUG=1\033[0m");
    end

    $timeformat(-9, 0, "ns", 6);
    test_passed = 1;

    apply_reset();
    start_clock(TP);

    @(posedge clk_o);

    while (u_div_cov.get_inst_coverage() < 100) begin
      realtime measured_timeperiod;
      real deviation;

      @(posedge clk_i);
      div_i <= $urandom;

      // let divider settle
      repeat (2) @(posedge clk_o);

      // Measure the time between 100 output clock edges to get an average period
      measured_timeperiod = $realtime;
      repeat (SAMPLE_CYCLES) @(posedge clk_o);
      measured_timeperiod = $realtime - measured_timeperiod;
      measured_timeperiod = measured_timeperiod / SAMPLE_CYCLES;

      deviation = (TP * (div_i == 0 ? 1 : div_i)) / measured_timeperiod;
      deviation = deviation - 1;

      if (deviation > -0.02 && deviation < 0.02) begin
      end else begin
        $display("Division Failed for div_i=%0d [%0t]", div_i, $realtime);
        $display("Measured Period: %0t, Expected Period: %0t\n", measured_timeperiod,
                 TP * (div_i == 0 ? 1 : div_i));
        test_passed = 0;
      end

    end

    repeat (50) @(clk_i);

    if (test_passed) $display("\033[1;32m************** TEST PASSED **************\033[0m");
    else $display("\033[1;31m************** TEST FAILED **************\033[0m");

    #100ns;

    $finish;

  end

endmodule
