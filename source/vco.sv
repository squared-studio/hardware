// Write a markdown documentation for this systemverilog module:
// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2025 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module vco (
    input logic arst_ni,  // active low asynchronous reset
    input logic freq_incr_i,  // increase frequency
    input logic freq_decr_i,  // decrease frequency
    input logic stable_cfg,  // configuration is stable

    output logic clk_o,
    output logic locked_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam realtime MIN_CLK_HALF_PERIOD = 50ps;  // Minimum allowed clock half period
  localparam realtime MAX_CLK_HALF_PERIOD = 0.5ms;  // Maximum allowed clock half period

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  realtime        clk_half_period;  // Variable to store the current clock half period
  realtime        last_clk_tick;  // Variable to store the last clock tick time
  bit             incr_ok;  // Flag to indicate if frequency increment is valid
  bit             decr_ok;  // Flag to indicate if frequency decrement is valid
  event           update;  // Event to trigger clock update
  logic           locked_internal;  // Internal signal to indicate if the VCO is locked
  logic    [15:0] locked_array;  // Array to track the locking status over multiple clock cycles

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign locked_internal = arst_ni & decr_ok & incr_ok & stable_cfg; // VCO is locked if reset is de-asserted, increment and decrement are valid, and stable configuration is set.
  assign locked_o = locked_array[15]; // Output the most significant bit of the locked array, indicating locked status.

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Frequency Increment Validation
  always @(posedge freq_incr_i) begin
    realtime time_record;
    if (arst_ni) begin  // Only check when reset is de-asserted
      time_record = $realtime;  // Record the current time
      @(negedge freq_incr_i);  // Wait for the falling edge of the increment signal
      time_record = $realtime - time_record;  // Calculate the pulse width of the increment signal
      if (time_record < MIN_CLK_HALF_PERIOD) begin // Check if the pulse width is less than the minimum allowed half period
        incr_ok = '1;  // If yes, set the increment flag to valid
      end else begin
        incr_ok = '0;  // Otherwise, set the increment flag to invalid
      end
    end
  end

  // Frequency Decrement Validation
  always @(posedge freq_decr_i) begin
    realtime time_record;
    if (arst_ni) begin  // Only check when reset is de-asserted
      time_record = $realtime;  // Record the current time
      @(negedge freq_decr_i);  // Wait for the falling edge of the decrement signal
      time_record = $realtime - time_record;  // Calculate the pulse width of the decrement signal
      if (time_record < MIN_CLK_HALF_PERIOD) begin // Check if the pulse width is less than the minimum allowed half period
        decr_ok = '1;  // If yes, set the decrement flag to valid
      end else begin
        decr_ok = '0;  // Otherwise, set the decrement flag to invalid
      end
    end
  end

  // Reset Trigger Event
  always @(negedge arst_ni) begin
    ->update;  // Trigger the update event when reset is asserted
  end

  // Periodic Trigger Event
  always #25ps begin
    ->update;
  end

  // Clock Generation Logic
  always @(update) begin
    if (~arst_ni) begin  // If reset is asserted
      incr_ok = '0;  // Reset increment flag
      decr_ok = '0;  // Reset decrement flag
      clk_o <= '0;  // Reset clock output
      last_clk_tick <= $realtime;  // Initialize last clock tick time
      clk_half_period <= 1us;  // Initialize clock half period to 1us
    end else begin  // If reset is de-asserted
      if (freq_incr_i & ~freq_decr_i)
        clk_half_period = clk_half_period - 1ps; // Decrement clock half period if only increment is active
      if (freq_decr_i & ~freq_incr_i)
        clk_half_period = clk_half_period + 1ps; // Increment clock half period if only decrement is active

      if (clk_half_period < MIN_CLK_HALF_PERIOD)
        clk_half_period = MIN_CLK_HALF_PERIOD;  // Limit clock half period to minimum value
      if (clk_half_period > MAX_CLK_HALF_PERIOD)
        clk_half_period = MAX_CLK_HALF_PERIOD;  // Limit clock half period to maximum value

      if (($realtime) >= (last_clk_tick + clk_half_period)) begin // If current time is greater than or equal to the last clock tick plus half period
        clk_o <= ~clk_o;  // Toggle the clock output
        last_clk_tick <= $realtime;  // Update the last clock tick time
      end
    end
  end

  // Locking Logic
  always_ff @(posedge clk_o or negedge locked_internal) begin
    if (~locked_internal) begin  // If VCO is not locked
      locked_array <= '0;  // Reset the locking array
    end else begin  // If VCO is locked
      locked_array <= {locked_array[14:0], 1'b1};  // Shift in a '1' to the locking array.
      // This creates a history of the VCO being locked.
      // The MSB of the array indicates if the VCO has been locked for a
      // certain number of clock cycles, improving robustness.
    end
  end

endmodule
