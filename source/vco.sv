module vco #(
    parameter int MIN_FREQ_HZ     = 100E3,  // 100 kHz
    parameter int MAX_FREQ_HZ     = 10E9,   // 10 GHz
    parameter int RESOLUTION_BITS = 32      // 32-bit resolution for frequency control word
) (
    input  logic [RESOLUTION_BITS-1:0] voltage_ctrl_i,  // Control voltage input for VCO
    output logic                       clk_o
);

  realtime last_tick_time = 0.0;
  realtime next_tick_time = 500ms / MIN_FREQ_HZ;

  realtime freq_hz;
  real factor;

  logic [RESOLUTION_BITS-1:0] max_voltage_ctrl = 2 ** RESOLUTION_BITS - 1;

  logic clk = 0;

  always #10ps begin
    real v_in;
    real v_max;
    if ($realtime >= next_tick_time) begin
      clk <= ~clk;
      last_tick_time = $realtime;
    end
    v_in = real'(unsigned'(voltage_ctrl_i));
    v_max = real'(unsigned'(max_voltage_ctrl));
    factor = v_in / v_max;
    freq_hz = factor * (MAX_FREQ_HZ - MIN_FREQ_HZ) + MIN_FREQ_HZ;
    next_tick_time = last_tick_time + (500ms / freq_hz);
  end

  assign clk_o = clk;

endmodule
