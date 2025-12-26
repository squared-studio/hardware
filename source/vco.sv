module vco #(
    parameter real MIN_FREQ_HZ     = 100E3,  // 100 kHz
    parameter real MAX_FREQ_HZ     = 10E9,   // 10 GHz
    parameter int  RESOLUTION_BITS = 20      // 20-bit resolution for frequency control word
) (
    input  logic [RESOLUTION_BITS-1:0] voltage_ctrl_i,  // Control voltage input for VCO
    output logic                       clk_o
);

  realtime last_tick_time = 0.0;
  realtime next_tick_time = 500ms / MIN_FREQ_HZ;

  logic clk = 0;

  always #1ps begin
    real v_in;
    real v_max;
    real factor;
    real freq_hz;
    if ($realtime >= next_tick_time) begin
      clk <= ~clk;
      last_tick_time = next_tick_time;
    end
    v_in = real'(unsigned'(voltage_ctrl_i));
    v_max = real'(unsigned'(2 ** RESOLUTION_BITS - 1));
    factor = v_in / v_max;
    freq_hz = factor * (MAX_FREQ_HZ - MIN_FREQ_HZ) + MIN_FREQ_HZ;
    next_tick_time = last_tick_time + (500ms / freq_hz);
  end

  assign clk_o = clk;

endmodule
