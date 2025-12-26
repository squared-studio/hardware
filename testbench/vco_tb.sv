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

  initial begin
    $dumpfile("vco_tb.vcd");
    $dumpvars(0, vco_tb);
    fork
      begin
        forever #1us $display("Time: %0tus", $realtime / 1us);
      end
    join_none
    voltage_ctrl_i <= 0;
    #1us;
    voltage_ctrl_i <= (2 ** RESOLUTION_BITS - 1) / 4;  // 25% of max frequency
    #1us;
    voltage_ctrl_i <= (2 ** RESOLUTION_BITS - 1) / 2;  // 50% of max frequency
    #1us;
    voltage_ctrl_i <= (3 * (2 ** RESOLUTION_BITS - 1)) / 4;  // 75% of max frequency
    #1us;
    voltage_ctrl_i <= (2 ** RESOLUTION_BITS - 1);  // Max frequency
    #1us;
    $finish;
  end

endmodule
