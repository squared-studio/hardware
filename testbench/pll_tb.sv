module pll_tb;
  // Define the width of the reference divider input
  localparam int REF_DEV_WIDTH = 4;
  // Define the width of the feedback divider input
  localparam int FB_DIV_WIDTH = 8;

  // Declare the signals used in the testbench
  logic                     arst_ni;  // Asynchronous reset input (active low)
  logic                     clk_ref_i;  // Reference clock input
  logic [REF_DEV_WIDTH-1:0] refdiv_i;  // Reference divider input
  logic [ FB_DIV_WIDTH-1:0] fbdiv_i;  // Feedback divider input
  logic                     clk_o;  // PLL output clock
  logic                     locked_o;  // PLL lock indicator

  // Instantiate the PLL module
  pll #(
      .REF_DEV_WIDTH(4),  // Pass the reference divider width parameter
      .FB_DIV_WIDTH (8)   // Pass the feedback divider width parameter
  ) u_pll (
      .arst_ni,  // Connect the asynchronous reset input
      .clk_ref_i,  // Connect the reference clock input
      .refdiv_i,  // Connect the reference divider input
      .fbdiv_i,  // Connect the feedback divider input
      .clk_o,  // Connect the PLL output clock
      .locked_o  // Connect the PLL lock indicator
  );

  // Testbench stimulus
  initial begin
    // Initialize the waveform dump
    $dumpfile("pll_tb.vcd");
    $dumpvars(0, pll_tb);

    // Initial setup and reset sequence
    #100ns;
    arst_ni   <= '0;  // Assert reset
    clk_ref_i <= '0;  // Initialize the reference clock
    refdiv_i  <= '0;  // Initialize the reference divider
    fbdiv_i   <= '0;  // Initialize the feedback divider

    #100ns;
    arst_ni <= '1;  // De-assert reset

    // Clock generation
    #100ns;
    fork
      forever begin
        clk_ref_i <= ~clk_ref_i;  // Toggle the reference clock every 5ns (100MHz)
        #5ns;
      end
    join_none

    // Simulation control and test sequence
    #4us;
    refdiv_i <= 2;  // Set the reference divider to 2
    #4us;
    fbdiv_i <= 2;  // Set the feedback divider to 2
    #4us;
    fbdiv_i <= 4;  // Set the feedback divider to 4
    #4us;
    refdiv_i <= 1;  // Set the reference divider to 1
    #4us;
    $finish;  // End the simulation
  end
endmodule
