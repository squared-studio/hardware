// Description
// Author : Foez Ahmed (foez.official@gmail.com)
// This file is part of squared-studio : hardware
// Copyright (c) 2026 squared-studio
// Licensed under the MIT License
// See LICENSE file in the repository root for full license information

module encoder_8b10b_tb;

  logic       clk;

  logic [7:0] data_i;
  logic       k_char_i;
  logic       running_disparity_i;
  logic [9:0] data_o;
  logic       is_legal_o;
  logic       running_disparity_o;

  encoder_8b10b u_encoder (
      .data_i,
      .k_char_i,
      .running_disparity_i,
      .data_o,
      .is_legal_o,
      .running_disparity_o
  );

  task static start_clock();
    fork
      forever begin
        clk <= '1;
        #5ns;
        clk <= '0;
        #5ns;
      end
    join_none
  endtask

  task static apply_reset();
    #100ns;
    clk                 <= '0;
    data_i              <= '0;
    k_char_i            <= '0;
    running_disparity_i <= '0;
    #100ns;
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  function automatic bit [9:0] encode(input bit k, input bit [7:0] data, input bit disparity);
    case ({
      k, data
    })
      'b000000000: return (disparity ? 'b0110001011 : 'b1001110100);  // D0_0
      'b000000001: return (disparity ? 'b1000101011 : 'b0111010100);  // D1_0
      'b000000010: return (disparity ? 'b0100101011 : 'b1011010100);  // D2_0
      'b000000011: return (disparity ? 'b1100010100 : 'b1100011011);  // D3_0
      'b000000100: return (disparity ? 'b0010101011 : 'b1101010100);  // D4_0
      'b000000101: return (disparity ? 'b1010010100 : 'b1010011011);  // D5_0
      'b000000110: return (disparity ? 'b0110010100 : 'b0110011011);  // D6_0
      'b000000111: return (disparity ? 'b0001110100 : 'b1110001011);  // D7_0
      'b000001000: return (disparity ? 'b0001101011 : 'b1110010100);  // D8_0
      'b000001001: return (disparity ? 'b1001010100 : 'b1001011011);  // D9_0
      'b000001010: return (disparity ? 'b0101010100 : 'b0101011011);  // D10_0
      'b000001011: return (disparity ? 'b1101000100 : 'b1101001011);  // D11_0
      'b000001100: return (disparity ? 'b0011010100 : 'b0011011011);  // D12_0
      'b000001101: return (disparity ? 'b1011000100 : 'b1011001011);  // D13_0
      'b000001110: return (disparity ? 'b0111000100 : 'b0111001011);  // D14_0
      'b000001111: return (disparity ? 'b1010001011 : 'b0101110100);  // D15_0
      'b000010000: return (disparity ? 'b1001001011 : 'b0110110100);  // D16_0
      'b000010001: return (disparity ? 'b1000110100 : 'b1000111011);  // D17_0
      'b000010010: return (disparity ? 'b0100110100 : 'b0100111011);  // D18_0
      'b000010011: return (disparity ? 'b1100100100 : 'b1100101011);  // D19_0
      'b000010100: return (disparity ? 'b0010110100 : 'b0010111011);  // D20_0
      'b000010101: return (disparity ? 'b1010100100 : 'b1010101011);  // D21_0
      'b000010110: return (disparity ? 'b0110100100 : 'b0110101011);  // D22_0
      'b000010111: return (disparity ? 'b0001011011 : 'b1110100100);  // D23_0
      'b000011000: return (disparity ? 'b0011001011 : 'b1100110100);  // D24_0
      'b000011001: return (disparity ? 'b1001100100 : 'b1001101011);  // D25_0
      'b000011010: return (disparity ? 'b0101100100 : 'b0101101011);  // D26_0
      'b000011011: return (disparity ? 'b0010011011 : 'b1101100100);  // D27_0
      'b000011100: return (disparity ? 'b0011100100 : 'b0011101011);  // D28_0
      'b000011101: return (disparity ? 'b0100011011 : 'b1011100100);  // D29_0
      'b000011110: return (disparity ? 'b1000011011 : 'b0111100100);  // D30_0
      'b000011111: return (disparity ? 'b0101001011 : 'b1010110100);  // D31_0
      'b000100000: return (disparity ? 'b0110001001 : 'b1001111001);  // D0_1
      'b000100001: return (disparity ? 'b1000101001 : 'b0111011001);  // D1_1
      'b000100010: return (disparity ? 'b0100101001 : 'b1011011001);  // D2_1
      'b000100011: return (disparity ? 'b1100011001 : 'b1100011001);  // D3_1
      'b000100100: return (disparity ? 'b0010101001 : 'b1101011001);  // D4_1
      'b000100101: return (disparity ? 'b1010011001 : 'b1010011001);  // D5_1
      'b000100110: return (disparity ? 'b0110011001 : 'b0110011001);  // D6_1
      'b000100111: return (disparity ? 'b0001111001 : 'b1110001001);  // D7_1
      'b000101000: return (disparity ? 'b0001101001 : 'b1110011001);  // D8_1
      'b000101001: return (disparity ? 'b1001011001 : 'b1001011001);  // D9_1
      'b000101010: return (disparity ? 'b0101011001 : 'b0101011001);  // D10_1
      'b000101011: return (disparity ? 'b1101001001 : 'b1101001001);  // D11_1
      'b000101100: return (disparity ? 'b0011011001 : 'b0011011001);  // D12_1
      'b000101101: return (disparity ? 'b1011001001 : 'b1011001001);  // D13_1
      'b000101110: return (disparity ? 'b0111001001 : 'b0111001001);  // D14_1
      'b000101111: return (disparity ? 'b1010001001 : 'b0101111001);  // D15_1
      'b000110000: return (disparity ? 'b1001001001 : 'b0110111001);  // D16_1
      'b000110001: return (disparity ? 'b1000111001 : 'b1000111001);  // D17_1
      'b000110010: return (disparity ? 'b0100111001 : 'b0100111001);  // D18_1
      'b000110011: return (disparity ? 'b1100101001 : 'b1100101001);  // D19_1
      'b000110100: return (disparity ? 'b0010111001 : 'b0010111001);  // D20_1
      'b000110101: return (disparity ? 'b1010101001 : 'b1010101001);  // D21_1
      'b000110110: return (disparity ? 'b0110101001 : 'b0110101001);  // D22_1
      'b000110111: return (disparity ? 'b0001011001 : 'b1110101001);  // D23_1
      'b000111000: return (disparity ? 'b0011001001 : 'b1100111001);  // D24_1
      'b000111001: return (disparity ? 'b1001101001 : 'b1001101001);  // D25_1
      'b000111010: return (disparity ? 'b0101101001 : 'b0101101001);  // D26_1
      'b000111011: return (disparity ? 'b0010011001 : 'b1101101001);  // D27_1
      'b000111100: return (disparity ? 'b0011101001 : 'b0011101001);  // D28_1
      'b000111101: return (disparity ? 'b0100011001 : 'b1011101001);  // D29_1
      'b000111110: return (disparity ? 'b1000011001 : 'b0111101001);  // D30_1
      'b000111111: return (disparity ? 'b0101001001 : 'b1010111001);  // D31_1
      'b001000000: return (disparity ? 'b0110000101 : 'b1001110101);  // D0_2
      'b001000001: return (disparity ? 'b1000100101 : 'b0111010101);  // D1_2
      'b001000010: return (disparity ? 'b0100100101 : 'b1011010101);  // D2_2
      'b001000011: return (disparity ? 'b1100010101 : 'b1100010101);  // D3_2
      'b001000100: return (disparity ? 'b0010100101 : 'b1101010101);  // D4_2
      'b001000101: return (disparity ? 'b1010010101 : 'b1010010101);  // D5_2
      'b001000110: return (disparity ? 'b0110010101 : 'b0110010101);  // D6_2
      'b001000111: return (disparity ? 'b0001110101 : 'b1110000101);  // D7_2
      'b001001000: return (disparity ? 'b0001100101 : 'b1110010101);  // D8_2
      'b001001001: return (disparity ? 'b1001010101 : 'b1001010101);  // D9_2
      'b001001010: return (disparity ? 'b0101010101 : 'b0101010101);  // D10_2
      'b001001011: return (disparity ? 'b1101000101 : 'b1101000101);  // D11_2
      'b001001100: return (disparity ? 'b0011010101 : 'b0011010101);  // D12_2
      'b001001101: return (disparity ? 'b1011000101 : 'b1011000101);  // D13_2
      'b001001110: return (disparity ? 'b0111000101 : 'b0111000101);  // D14_2
      'b001001111: return (disparity ? 'b1010000101 : 'b0101110101);  // D15_2
      'b001010000: return (disparity ? 'b1001000101 : 'b0110110101);  // D16_2
      'b001010001: return (disparity ? 'b1000110101 : 'b1000110101);  // D17_2
      'b001010010: return (disparity ? 'b0100110101 : 'b0100110101);  // D18_2
      'b001010011: return (disparity ? 'b1100100101 : 'b1100100101);  // D19_2
      'b001010100: return (disparity ? 'b0010110101 : 'b0010110101);  // D20_2
      'b001010101: return (disparity ? 'b1010100101 : 'b1010100101);  // D21_2
      'b001010110: return (disparity ? 'b0110100101 : 'b0110100101);  // D22_2
      'b001010111: return (disparity ? 'b0001010101 : 'b1110100101);  // D23_2
      'b001011000: return (disparity ? 'b0011000101 : 'b1100110101);  // D24_2
      'b001011001: return (disparity ? 'b1001100101 : 'b1001100101);  // D25_2
      'b001011010: return (disparity ? 'b0101100101 : 'b0101100101);  // D26_2
      'b001011011: return (disparity ? 'b0010010101 : 'b1101100101);  // D27_2
      'b001011100: return (disparity ? 'b0011100101 : 'b0011100101);  // D28_2
      'b001011101: return (disparity ? 'b0100010101 : 'b1011100101);  // D29_2
      'b001011110: return (disparity ? 'b1000010101 : 'b0111100101);  // D30_2
      'b001011111: return (disparity ? 'b0101000101 : 'b1010110101);  // D31_2
      'b001100000: return (disparity ? 'b0110001100 : 'b1001110011);  // D0_3
      'b001100001: return (disparity ? 'b1000101100 : 'b0111010011);  // D1_3
      'b001100010: return (disparity ? 'b0100101100 : 'b1011010011);  // D2_3
      'b001100011: return (disparity ? 'b1100010011 : 'b1100011100);  // D3_3
      'b001100100: return (disparity ? 'b0010101100 : 'b1101010011);  // D4_3
      'b001100101: return (disparity ? 'b1010010011 : 'b1010011100);  // D5_3
      'b001100110: return (disparity ? 'b0110010011 : 'b0110011100);  // D6_3
      'b001100111: return (disparity ? 'b0001110011 : 'b1110001100);  // D7_3
      'b001101000: return (disparity ? 'b0001101100 : 'b1110010011);  // D8_3
      'b001101001: return (disparity ? 'b1001010011 : 'b1001011100);  // D9_3
      'b001101010: return (disparity ? 'b0101010011 : 'b0101011100);  // D10_3
      'b001101011: return (disparity ? 'b1101000011 : 'b1101001100);  // D11_3
      'b001101100: return (disparity ? 'b0011010011 : 'b0011011100);  // D12_3
      'b001101101: return (disparity ? 'b1011000011 : 'b1011001100);  // D13_3
      'b001101110: return (disparity ? 'b0111000011 : 'b0111001100);  // D14_3
      'b001101111: return (disparity ? 'b1010001100 : 'b0101110011);  // D15_3
      'b001110000: return (disparity ? 'b1001001100 : 'b0110110011);  // D16_3
      'b001110001: return (disparity ? 'b1000110011 : 'b1000111100);  // D17_3
      'b001110010: return (disparity ? 'b0100110011 : 'b0100111100);  // D18_3
      'b001110011: return (disparity ? 'b1100100011 : 'b1100101100);  // D19_3
      'b001110100: return (disparity ? 'b0010110011 : 'b0010111100);  // D20_3
      'b001110101: return (disparity ? 'b1010100011 : 'b1010101100);  // D21_3
      'b001110110: return (disparity ? 'b0110100011 : 'b0110101100);  // D22_3
      'b001110111: return (disparity ? 'b0001011100 : 'b1110100011);  // D23_3
      'b001111000: return (disparity ? 'b0011001100 : 'b1100110011);  // D24_3
      'b001111001: return (disparity ? 'b1001100011 : 'b1001101100);  // D25_3
      'b001111010: return (disparity ? 'b0101100011 : 'b0101101100);  // D26_3
      'b001111011: return (disparity ? 'b0010011100 : 'b1101100011);  // D27_3
      'b001111100: return (disparity ? 'b0011100011 : 'b0011101100);  // D28_3
      'b001111101: return (disparity ? 'b0100011100 : 'b1011100011);  // D29_3
      'b001111110: return (disparity ? 'b1000011100 : 'b0111100011);  // D30_3
      'b001111111: return (disparity ? 'b0101001100 : 'b1010110011);  // D31_3
      'b010000000: return (disparity ? 'b0110001101 : 'b1001110010);  // D0_4
      'b010000001: return (disparity ? 'b1000101101 : 'b0111010010);  // D1_4
      'b010000010: return (disparity ? 'b0100101101 : 'b1011010010);  // D2_4
      'b010000011: return (disparity ? 'b1100010010 : 'b1100011101);  // D3_4
      'b010000100: return (disparity ? 'b0010101101 : 'b1101010010);  // D4_4
      'b010000101: return (disparity ? 'b1010010010 : 'b1010011101);  // D5_4
      'b010000110: return (disparity ? 'b0110010010 : 'b0110011101);  // D6_4
      'b010000111: return (disparity ? 'b0001110010 : 'b1110001101);  // D7_4
      'b010001000: return (disparity ? 'b0001101101 : 'b1110010010);  // D8_4
      'b010001001: return (disparity ? 'b1001010010 : 'b1001011101);  // D9_4
      'b010001010: return (disparity ? 'b0101010010 : 'b0101011101);  // D10_4
      'b010001011: return (disparity ? 'b1101000010 : 'b1101001101);  // D11_4
      'b010001100: return (disparity ? 'b0011010010 : 'b0011011101);  // D12_4
      'b010001101: return (disparity ? 'b1011000010 : 'b1011001101);  // D13_4
      'b010001110: return (disparity ? 'b0111000010 : 'b0111001101);  // D14_4
      'b010001111: return (disparity ? 'b1010001101 : 'b0101110010);  // D15_4
      'b010010000: return (disparity ? 'b1001001101 : 'b0110110010);  // D16_4
      'b010010001: return (disparity ? 'b1000110010 : 'b1000111101);  // D17_4
      'b010010010: return (disparity ? 'b0100110010 : 'b0100111101);  // D18_4
      'b010010011: return (disparity ? 'b1100100010 : 'b1100101101);  // D19_4
      'b010010100: return (disparity ? 'b0010110010 : 'b0010111101);  // D20_4
      'b010010101: return (disparity ? 'b1010100010 : 'b1010101101);  // D21_4
      'b010010110: return (disparity ? 'b0110100010 : 'b0110101101);  // D22_4
      'b010010111: return (disparity ? 'b0001011101 : 'b1110100010);  // D23_4
      'b010011000: return (disparity ? 'b0011001101 : 'b1100110010);  // D24_4
      'b010011001: return (disparity ? 'b1001100010 : 'b1001101101);  // D25_4
      'b010011010: return (disparity ? 'b0101100010 : 'b0101101101);  // D26_4
      'b010011011: return (disparity ? 'b0010011101 : 'b1101100010);  // D27_4
      'b010011100: return (disparity ? 'b0011100010 : 'b0011101101);  // D28_4
      'b010011101: return (disparity ? 'b0100011101 : 'b1011100010);  // D29_4
      'b010011110: return (disparity ? 'b1000011101 : 'b0111100010);  // D30_4
      'b010011111: return (disparity ? 'b0101001101 : 'b1010110010);  // D31_4
      'b010100000: return (disparity ? 'b0110001010 : 'b1001111010);  // D0_5
      'b010100001: return (disparity ? 'b1000101010 : 'b0111011010);  // D1_5
      'b010100010: return (disparity ? 'b0100101010 : 'b1011011010);  // D2_5
      'b010100011: return (disparity ? 'b1100011010 : 'b1100011010);  // D3_5
      'b010100100: return (disparity ? 'b0010101010 : 'b1101011010);  // D4_5
      'b010100101: return (disparity ? 'b1010011010 : 'b1010011010);  // D5_5
      'b010100110: return (disparity ? 'b0110011010 : 'b0110011010);  // D6_5
      'b010100111: return (disparity ? 'b0001111010 : 'b1110001010);  // D7_5
      'b010101000: return (disparity ? 'b0001101010 : 'b1110011010);  // D8_5
      'b010101001: return (disparity ? 'b1001011010 : 'b1001011010);  // D9_5
      'b010101010: return (disparity ? 'b0101011010 : 'b0101011010);  // D10_5
      'b010101011: return (disparity ? 'b1101001010 : 'b1101001010);  // D11_5
      'b010101100: return (disparity ? 'b0011011010 : 'b0011011010);  // D12_5
      'b010101101: return (disparity ? 'b1011001010 : 'b1011001010);  // D13_5
      'b010101110: return (disparity ? 'b0111001010 : 'b0111001010);  // D14_5
      'b010101111: return (disparity ? 'b1010001010 : 'b0101111010);  // D15_5
      'b010110000: return (disparity ? 'b1001001010 : 'b0110111010);  // D16_5
      'b010110001: return (disparity ? 'b1000111010 : 'b1000111010);  // D17_5
      'b010110010: return (disparity ? 'b0100111010 : 'b0100111010);  // D18_5
      'b010110011: return (disparity ? 'b1100101010 : 'b1100101010);  // D19_5
      'b010110100: return (disparity ? 'b0010111010 : 'b0010111010);  // D20_5
      'b010110101: return (disparity ? 'b1010101010 : 'b1010101010);  // D21_5
      'b010110110: return (disparity ? 'b0110101010 : 'b0110101010);  // D22_5
      'b010110111: return (disparity ? 'b0001011010 : 'b1110101010);  // D23_5
      'b010111000: return (disparity ? 'b0011001010 : 'b1100111010);  // D24_5
      'b010111001: return (disparity ? 'b1001101010 : 'b1001101010);  // D25_5
      'b010111010: return (disparity ? 'b0101101010 : 'b0101101010);  // D26_5
      'b010111011: return (disparity ? 'b0010011010 : 'b1101101010);  // D27_5
      'b010111100: return (disparity ? 'b0011101010 : 'b0011101010);  // D28_5
      'b010111101: return (disparity ? 'b0100011010 : 'b1011101010);  // D29_5
      'b010111110: return (disparity ? 'b1000011010 : 'b0111101010);  // D30_5
      'b010111111: return (disparity ? 'b0101001010 : 'b1010111010);  // D31_5
      'b011000000: return (disparity ? 'b0110000110 : 'b1001110110);  // D0_6
      'b011000001: return (disparity ? 'b1000100110 : 'b0111010110);  // D1_6
      'b011000010: return (disparity ? 'b0100100110 : 'b1011010110);  // D2_6
      'b011000011: return (disparity ? 'b1100010110 : 'b1100010110);  // D3_6
      'b011000100: return (disparity ? 'b0010100110 : 'b1101010110);  // D4_6
      'b011000101: return (disparity ? 'b1010010110 : 'b1010010110);  // D5_6
      'b011000110: return (disparity ? 'b0110010110 : 'b0110010110);  // D6_6
      'b011000111: return (disparity ? 'b0001110110 : 'b1110000110);  // D7_6
      'b011001000: return (disparity ? 'b0001100110 : 'b1110010110);  // D8_6
      'b011001001: return (disparity ? 'b1001010110 : 'b1001010110);  // D9_6
      'b011001010: return (disparity ? 'b0101010110 : 'b0101010110);  // D10_6
      'b011001011: return (disparity ? 'b1101000110 : 'b1101000110);  // D11_6
      'b011001100: return (disparity ? 'b0011010110 : 'b0011010110);  // D12_6
      'b011001101: return (disparity ? 'b1011000110 : 'b1011000110);  // D13_6
      'b011001110: return (disparity ? 'b0111000110 : 'b0111000110);  // D14_6
      'b011001111: return (disparity ? 'b1010000110 : 'b0101110110);  // D15_6
      'b011010000: return (disparity ? 'b1001000110 : 'b0110110110);  // D16_6
      'b011010001: return (disparity ? 'b1000110110 : 'b1000110110);  // D17_6
      'b011010010: return (disparity ? 'b0100110110 : 'b0100110110);  // D18_6
      'b011010011: return (disparity ? 'b1100100110 : 'b1100100110);  // D19_6
      'b011010100: return (disparity ? 'b0010110110 : 'b0010110110);  // D20_6
      'b011010101: return (disparity ? 'b1010100110 : 'b1010100110);  // D21_6
      'b011010110: return (disparity ? 'b0110100110 : 'b0110100110);  // D22_6
      'b011010111: return (disparity ? 'b0001010110 : 'b1110100110);  // D23_6
      'b011011000: return (disparity ? 'b0011000110 : 'b1100110110);  // D24_6
      'b011011001: return (disparity ? 'b1001100110 : 'b1001100110);  // D25_6
      'b011011010: return (disparity ? 'b0101100110 : 'b0101100110);  // D26_6
      'b011011011: return (disparity ? 'b0010010110 : 'b1101100110);  // D27_6
      'b011011100: return (disparity ? 'b0011100110 : 'b0011100110);  // D28_6
      'b011011101: return (disparity ? 'b0100010110 : 'b1011100110);  // D29_6
      'b011011110: return (disparity ? 'b1000010110 : 'b0111100110);  // D30_6
      'b011011111: return (disparity ? 'b0101000110 : 'b1010110110);  // D31_6
      'b011100000: return (disparity ? 'b0110001110 : 'b1001110001);  // D0_7
      'b011100001: return (disparity ? 'b1000101110 : 'b0111010001);  // D1_7
      'b011100010: return (disparity ? 'b0100101110 : 'b1011010001);  // D2_7
      'b011100011: return (disparity ? 'b1100010001 : 'b1100011110);  // D3_7
      'b011100100: return (disparity ? 'b0010101110 : 'b1101010001);  // D4_7
      'b011100101: return (disparity ? 'b1010010001 : 'b1010011110);  // D5_7
      'b011100110: return (disparity ? 'b0110010001 : 'b0110011110);  // D6_7
      'b011100111: return (disparity ? 'b0001110001 : 'b1110001110);  // D7_7
      'b011101000: return (disparity ? 'b0001101110 : 'b1110010001);  // D8_7
      'b011101001: return (disparity ? 'b1001010001 : 'b1001011110);  // D9_7
      'b011101010: return (disparity ? 'b0101010001 : 'b0101011110);  // D10_7
      'b011101011: return (disparity ? 'b1101001000 : 'b1101001110);  // D11_7
      'b011101100: return (disparity ? 'b0011010001 : 'b0011011110);  // D12_7
      'b011101101: return (disparity ? 'b1011001000 : 'b1011001110);  // D13_7
      'b011101110: return (disparity ? 'b0111001000 : 'b0111001110);  // D14_7
      'b011101111: return (disparity ? 'b1010001110 : 'b0101110001);  // D15_7
      'b011110000: return (disparity ? 'b1001001110 : 'b0110110001);  // D16_7
      'b011110001: return (disparity ? 'b1000110001 : 'b1000110111);  // D17_7
      'b011110010: return (disparity ? 'b0100110001 : 'b0100110111);  // D18_7
      'b011110011: return (disparity ? 'b1100100001 : 'b1100101110);  // D19_7
      'b011110100: return (disparity ? 'b0010110001 : 'b0010110111);  // D20_7
      'b011110101: return (disparity ? 'b1010100001 : 'b1010101110);  // D21_7
      'b011110110: return (disparity ? 'b0110100001 : 'b0110101110);  // D22_7
      'b011110111: return (disparity ? 'b0001011110 : 'b1110100001);  // D23_7
      'b011111000: return (disparity ? 'b0011001110 : 'b1100110001);  // D24_7
      'b011111001: return (disparity ? 'b1001100001 : 'b1001101110);  // D25_7
      'b011111010: return (disparity ? 'b0101100001 : 'b0101101110);  // D26_7
      'b011111011: return (disparity ? 'b0010011110 : 'b1101100001);  // D27_7
      'b011111100: return (disparity ? 'b0011100001 : 'b0011101110);  // D28_7
      'b011111101: return (disparity ? 'b0100011110 : 'b1011100001);  // D29_7
      'b011111110: return (disparity ? 'b1000011110 : 'b0111100001);  // D30_7
      'b011111111: return (disparity ? 'b0101001110 : 'b1010110001);  // D31_7
      'b100011100: return (disparity ? 'b1100001011 : 'b0011110100);  // K28_0
      'b100111100: return (disparity ? 'b1100000110 : 'b0011111001);  // K28_1
      'b101011100: return (disparity ? 'b1100001010 : 'b0011110101);  // K28_2
      'b101111100: return (disparity ? 'b1100001100 : 'b0011110011);  // K28_3
      'b110011100: return (disparity ? 'b1100001101 : 'b0011110010);  // K28_4
      'b110111100: return (disparity ? 'b1100000101 : 'b0011111010);  // K28_5
      'b111011100: return (disparity ? 'b1100001001 : 'b0011110110);  // K28_6
      'b111111100: return (disparity ? 'b1100000111 : 'b0011111000);  // K28_7
      'b111110111: return (disparity ? 'b0001010111 : 'b1110101000);  // K23_7
      'b111111011: return (disparity ? 'b0010010111 : 'b1101101000);  // K27_7
      'b111111101: return (disparity ? 'b0100010111 : 'b1011101000);  // K29_7
      'b111111110: return (disparity ? 'b1000010111 : 'b0111101000);  // K30_7
      default:     return 'b0000000000;  // ERROR
    endcase
  endfunction


  function automatic bit is_legal(input bit k, input bit [7:0] data);
    case (data)
      'b000000000: return 1'b1;  // D0_0
      'b000000001: return 1'b1;  // D1_0
      'b000000010: return 1'b1;  // D2_0
      'b000000011: return 1'b1;  // D3_0
      'b000000100: return 1'b1;  // D4_0
      'b000000101: return 1'b1;  // D5_0
      'b000000110: return 1'b1;  // D6_0
      'b000000111: return 1'b1;  // D7_0
      'b000001000: return 1'b1;  // D8_0
      'b000001001: return 1'b1;  // D9_0
      'b000001010: return 1'b1;  // D10_0
      'b000001011: return 1'b1;  // D11_0
      'b000001100: return 1'b1;  // D12_0
      'b000001101: return 1'b1;  // D13_0
      'b000001110: return 1'b1;  // D14_0
      'b000001111: return 1'b1;  // D15_0
      'b000010000: return 1'b1;  // D16_0
      'b000010001: return 1'b1;  // D17_0
      'b000010010: return 1'b1;  // D18_0
      'b000010011: return 1'b1;  // D19_0
      'b000010100: return 1'b1;  // D20_0
      'b000010101: return 1'b1;  // D21_0
      'b000010110: return 1'b1;  // D22_0
      'b000010111: return 1'b1;  // D23_0
      'b000011000: return 1'b1;  // D24_0
      'b000011001: return 1'b1;  // D25_0
      'b000011010: return 1'b1;  // D26_0
      'b000011011: return 1'b1;  // D27_0
      'b000011100: return 1'b1;  // D28_0
      'b000011101: return 1'b1;  // D29_0
      'b000011110: return 1'b1;  // D30_0
      'b000011111: return 1'b1;  // D31_0
      'b000100000: return 1'b1;  // D0_1
      'b000100001: return 1'b1;  // D1_1
      'b000100010: return 1'b1;  // D2_1
      'b000100011: return 1'b1;  // D3_1
      'b000100100: return 1'b1;  // D4_1
      'b000100101: return 1'b1;  // D5_1
      'b000100110: return 1'b1;  // D6_1
      'b000100111: return 1'b1;  // D7_1
      'b000101000: return 1'b1;  // D8_1
      'b000101001: return 1'b1;  // D9_1
      'b000101010: return 1'b1;  // D10_1
      'b000101011: return 1'b1;  // D11_1
      'b000101100: return 1'b1;  // D12_1
      'b000101101: return 1'b1;  // D13_1
      'b000101110: return 1'b1;  // D14_1
      'b000101111: return 1'b1;  // D15_1
      'b000110000: return 1'b1;  // D16_1
      'b000110001: return 1'b1;  // D17_1
      'b000110010: return 1'b1;  // D18_1
      'b000110011: return 1'b1;  // D19_1
      'b000110100: return 1'b1;  // D20_1
      'b000110101: return 1'b1;  // D21_1
      'b000110110: return 1'b1;  // D22_1
      'b000110111: return 1'b1;  // D23_1
      'b000111000: return 1'b1;  // D24_1
      'b000111001: return 1'b1;  // D25_1
      'b000111010: return 1'b1;  // D26_1
      'b000111011: return 1'b1;  // D27_1
      'b000111100: return 1'b1;  // D28_1
      'b000111101: return 1'b1;  // D29_1
      'b000111110: return 1'b1;  // D30_1
      'b000111111: return 1'b1;  // D31_1
      'b001000000: return 1'b1;  // D0_2
      'b001000001: return 1'b1;  // D1_2
      'b001000010: return 1'b1;  // D2_2
      'b001000011: return 1'b1;  // D3_2
      'b001000100: return 1'b1;  // D4_2
      'b001000101: return 1'b1;  // D5_2
      'b001000110: return 1'b1;  // D6_2
      'b001000111: return 1'b1;  // D7_2
      'b001001000: return 1'b1;  // D8_2
      'b001001001: return 1'b1;  // D9_2
      'b001001010: return 1'b1;  // D10_2
      'b001001011: return 1'b1;  // D11_2
      'b001001100: return 1'b1;  // D12_2
      'b001001101: return 1'b1;  // D13_2
      'b001001110: return 1'b1;  // D14_2
      'b001001111: return 1'b1;  // D15_2
      'b001010000: return 1'b1;  // D16_2
      'b001010001: return 1'b1;  // D17_2
      'b001010010: return 1'b1;  // D18_2
      'b001010011: return 1'b1;  // D19_2
      'b001010100: return 1'b1;  // D20_2
      'b001010101: return 1'b1;  // D21_2
      'b001010110: return 1'b1;  // D22_2
      'b001010111: return 1'b1;  // D23_2
      'b001011000: return 1'b1;  // D24_2
      'b001011001: return 1'b1;  // D25_2
      'b001011010: return 1'b1;  // D26_2
      'b001011011: return 1'b1;  // D27_2
      'b001011100: return 1'b1;  // D28_2
      'b001011101: return 1'b1;  // D29_2
      'b001011110: return 1'b1;  // D30_2
      'b001011111: return 1'b1;  // D31_2
      'b001100000: return 1'b1;  // D0_3
      'b001100001: return 1'b1;  // D1_3
      'b001100010: return 1'b1;  // D2_3
      'b001100011: return 1'b1;  // D3_3
      'b001100100: return 1'b1;  // D4_3
      'b001100101: return 1'b1;  // D5_3
      'b001100110: return 1'b1;  // D6_3
      'b001100111: return 1'b1;  // D7_3
      'b001101000: return 1'b1;  // D8_3
      'b001101001: return 1'b1;  // D9_3
      'b001101010: return 1'b1;  // D10_3
      'b001101011: return 1'b1;  // D11_3
      'b001101100: return 1'b1;  // D12_3
      'b001101101: return 1'b1;  // D13_3
      'b001101110: return 1'b1;  // D14_3
      'b001101111: return 1'b1;  // D15_3
      'b001110000: return 1'b1;  // D16_3
      'b001110001: return 1'b1;  // D17_3
      'b001110010: return 1'b1;  // D18_3
      'b001110011: return 1'b1;  // D19_3
      'b001110100: return 1'b1;  // D20_3
      'b001110101: return 1'b1;  // D21_3
      'b001110110: return 1'b1;  // D22_3
      'b001110111: return 1'b1;  // D23_3
      'b001111000: return 1'b1;  // D24_3
      'b001111001: return 1'b1;  // D25_3
      'b001111010: return 1'b1;  // D26_3
      'b001111011: return 1'b1;  // D27_3
      'b001111100: return 1'b1;  // D28_3
      'b001111101: return 1'b1;  // D29_3
      'b001111110: return 1'b1;  // D30_3
      'b001111111: return 1'b1;  // D31_3
      'b010000000: return 1'b1;  // D0_4
      'b010000001: return 1'b1;  // D1_4
      'b010000010: return 1'b1;  // D2_4
      'b010000011: return 1'b1;  // D3_4
      'b010000100: return 1'b1;  // D4_4
      'b010000101: return 1'b1;  // D5_4
      'b010000110: return 1'b1;  // D6_4
      'b010000111: return 1'b1;  // D7_4
      'b010001000: return 1'b1;  // D8_4
      'b010001001: return 1'b1;  // D9_4
      'b010001010: return 1'b1;  // D10_4
      'b010001011: return 1'b1;  // D11_4
      'b010001100: return 1'b1;  // D12_4
      'b010001101: return 1'b1;  // D13_4
      'b010001110: return 1'b1;  // D14_4
      'b010001111: return 1'b1;  // D15_4
      'b010010000: return 1'b1;  // D16_4
      'b010010001: return 1'b1;  // D17_4
      'b010010010: return 1'b1;  // D18_4
      'b010010011: return 1'b1;  // D19_4
      'b010010100: return 1'b1;  // D20_4
      'b010010101: return 1'b1;  // D21_4
      'b010010110: return 1'b1;  // D22_4
      'b010010111: return 1'b1;  // D23_4
      'b010011000: return 1'b1;  // D24_4
      'b010011001: return 1'b1;  // D25_4
      'b010011010: return 1'b1;  // D26_4
      'b010011011: return 1'b1;  // D27_4
      'b010011100: return 1'b1;  // D28_4
      'b010011101: return 1'b1;  // D29_4
      'b010011110: return 1'b1;  // D30_4
      'b010011111: return 1'b1;  // D31_4
      'b010100000: return 1'b1;  // D0_5
      'b010100001: return 1'b1;  // D1_5
      'b010100010: return 1'b1;  // D2_5
      'b010100011: return 1'b1;  // D3_5
      'b010100100: return 1'b1;  // D4_5
      'b010100101: return 1'b1;  // D5_5
      'b010100110: return 1'b1;  // D6_5
      'b010100111: return 1'b1;  // D7_5
      'b010101000: return 1'b1;  // D8_5
      'b010101001: return 1'b1;  // D9_5
      'b010101010: return 1'b1;  // D10_5
      'b010101011: return 1'b1;  // D11_5
      'b010101100: return 1'b1;  // D12_5
      'b010101101: return 1'b1;  // D13_5
      'b010101110: return 1'b1;  // D14_5
      'b010101111: return 1'b1;  // D15_5
      'b010110000: return 1'b1;  // D16_5
      'b010110001: return 1'b1;  // D17_5
      'b010110010: return 1'b1;  // D18_5
      'b010110011: return 1'b1;  // D19_5
      'b010110100: return 1'b1;  // D20_5
      'b010110101: return 1'b1;  // D21_5
      'b010110110: return 1'b1;  // D22_5
      'b010110111: return 1'b1;  // D23_5
      'b010111000: return 1'b1;  // D24_5
      'b010111001: return 1'b1;  // D25_5
      'b010111010: return 1'b1;  // D26_5
      'b010111011: return 1'b1;  // D27_5
      'b010111100: return 1'b1;  // D28_5
      'b010111101: return 1'b1;  // D29_5
      'b010111110: return 1'b1;  // D30_5
      'b010111111: return 1'b1;  // D31_5
      'b011000000: return 1'b1;  // D0_6
      'b011000001: return 1'b1;  // D1_6
      'b011000010: return 1'b1;  // D2_6
      'b011000011: return 1'b1;  // D3_6
      'b011000100: return 1'b1;  // D4_6
      'b011000101: return 1'b1;  // D5_6
      'b011000110: return 1'b1;  // D6_6
      'b011000111: return 1'b1;  // D7_6
      'b011001000: return 1'b1;  // D8_6
      'b011001001: return 1'b1;  // D9_6
      'b011001010: return 1'b1;  // D10_6
      'b011001011: return 1'b1;  // D11_6
      'b011001100: return 1'b1;  // D12_6
      'b011001101: return 1'b1;  // D13_6
      'b011001110: return 1'b1;  // D14_6
      'b011001111: return 1'b1;  // D15_6
      'b011010000: return 1'b1;  // D16_6
      'b011010001: return 1'b1;  // D17_6
      'b011010010: return 1'b1;  // D18_6
      'b011010011: return 1'b1;  // D19_6
      'b011010100: return 1'b1;  // D20_6
      'b011010101: return 1'b1;  // D21_6
      'b011010110: return 1'b1;  // D22_6
      'b011010111: return 1'b1;  // D23_6
      'b011011000: return 1'b1;  // D24_6
      'b011011001: return 1'b1;  // D25_6
      'b011011010: return 1'b1;  // D26_6
      'b011011011: return 1'b1;  // D27_6
      'b011011100: return 1'b1;  // D28_6
      'b011011101: return 1'b1;  // D29_6
      'b011011110: return 1'b1;  // D30_6
      'b011011111: return 1'b1;  // D31_6
      'b011100000: return 1'b1;  // D0_7
      'b011100001: return 1'b1;  // D1_7
      'b011100010: return 1'b1;  // D2_7
      'b011100011: return 1'b1;  // D3_7
      'b011100100: return 1'b1;  // D4_7
      'b011100101: return 1'b1;  // D5_7
      'b011100110: return 1'b1;  // D6_7
      'b011100111: return 1'b1;  // D7_7
      'b011101000: return 1'b1;  // D8_7
      'b011101001: return 1'b1;  // D9_7
      'b011101010: return 1'b1;  // D10_7
      'b011101011: return 1'b1;  // D11_7
      'b011101100: return 1'b1;  // D12_7
      'b011101101: return 1'b1;  // D13_7
      'b011101110: return 1'b1;  // D14_7
      'b011101111: return 1'b1;  // D15_7
      'b011110000: return 1'b1;  // D16_7
      'b011110001: return 1'b1;  // D17_7
      'b011110010: return 1'b1;  // D18_7
      'b011110011: return 1'b1;  // D19_7
      'b011110100: return 1'b1;  // D20_7
      'b011110101: return 1'b1;  // D21_7
      'b011110110: return 1'b1;  // D22_7
      'b011110111: return 1'b1;  // D23_7
      'b011111000: return 1'b1;  // D24_7
      'b011111001: return 1'b1;  // D25_7
      'b011111010: return 1'b1;  // D26_7
      'b011111011: return 1'b1;  // D27_7
      'b011111100: return 1'b1;  // D28_7
      'b011111101: return 1'b1;  // D29_7
      'b011111110: return 1'b1;  // D30_7
      'b011111111: return 1'b1;  // D31_7
      'b100011100: return 1'b1;  // K28_0
      'b100111100: return 1'b1;  // K28_1
      'b101011100: return 1'b1;  // K28_2
      'b101111100: return 1'b1;  // K28_3
      'b110011100: return 1'b1;  // K28_4
      'b110111100: return 1'b1;  // K28_5
      'b111011100: return 1'b1;  // K28_6
      'b111111100: return 1'b1;  // K28_7
      'b111110111: return 1'b1;  // K23_7
      'b111111011: return 1'b1;  // K27_7
      'b111111101: return 1'b1;  // K29_7
      'b111111110: return 1'b1;  // K30_7
      default:     return 1'b0;  // ERROR
    endcase

  endfunction
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    apply_reset();
    start_clock();

    for (int i = 0; i < 1024; i++) begin
      @(posedge clk);
      $write("K:%0b D:%0b 0b%08b --> 0b%010b ", k_char_i, running_disparity_i, data_i, data_o);
      if (data_o == encode(k_char_i, data_i, running_disparity_i)) begin
        $display("\033[1;32mPASS\033[0m");
      end else begin
        $display("\033[1;31mFAIL\033[0m EXPECTED: 0b%010b", encode(k_char_i, data_i,
                                                                   running_disparity_i));
      end
      {data_i, k_char_i, running_disparity_i} <= i;
    end

    $finish;

  end

endmodule
