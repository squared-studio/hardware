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
    do begin
      if (current_freq < target_freq) begin
        delta = target_freq - current_freq;
        if (voltage_ctrl_i != '1) voltage_ctrl_i = voltage_ctrl_i + 1;
      end else if (current_freq > target_freq) begin
        delta = current_freq - target_freq;
        if (voltage_ctrl_i != '0) voltage_ctrl_i = voltage_ctrl_i - 1;
      end else begin
        delta = 0;
      end
      #10ps;
    end while (delta > 100);
    #1us;
    $display("Reached target frequency: %0f (%0f) Hz with control voltage: %0d", current_freq,
             target_freq, voltage_ctrl_i);
  endtask

  initial begin
    $dumpfile("vco_tb.vcd");
    $dumpvars(0, vco_tb);
    fork
      begin
        int i;
        forever begin
          #1us;
          i++;
          $display("Time: %0d us", i);
        end
      end
    join_none
    voltage_ctrl_i <= 0;
    repeat (5) @(posedge clk_o);
    get_frequency(200E3);
    #100us;
    $finish;
  end

endmodule
