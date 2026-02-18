// Dual-edge storage using two edge flops and a clock-level mux on the output.
module dual_edge_register #(
    parameter int WIDTH = 8  // Width of the register
) (
    input logic arst_ni,  // active low asynchronous reset
    input logic clk_i,    // input clock

    input logic [WIDTH-1:0] data_i,  // data input
    input logic             en_i,    // enable signal for capturing data

    output logic [WIDTH-1:0] data_o  // data output
);

  logic [WIDTH-1:0] reg_pos;  // Register capturing data on the positive edge
  logic [WIDTH-1:0] reg_neg;  // Register capturing data on the negative edge

  // Combinational mux selects edge-captured data; note this lets clk_i level toggle data_o.
  always_comb begin
    data_o = clk_i ? reg_pos : reg_neg;
  end

  // Capture on rising edge; when disabled, mirror the opposite-edge sample.
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      reg_pos <= '0;
    end else if (en_i) begin
      reg_pos <= data_i;
    end else begin
      reg_pos <= reg_neg;
    end
  end

  // Capture on falling edge; when disabled, mirror the opposite-edge sample.
  always_ff @(negedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      reg_neg <= '0;
    end else if (en_i) begin
      reg_neg <= data_i;
    end else begin
      reg_neg <= reg_pos;
    end
  end

endmodule
