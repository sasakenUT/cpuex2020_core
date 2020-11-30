`timescale 1ns / 1ps
`default_nettype none

module test_regfile();

  // Inputs
  logic        clk;
  logic        we3;
  logic [4:0]  ra1, ra2, wa3;
  logic [31:0] wd3;

  // Outputs
  logic [31:0] rd1, rd2;

  // Simulation variables
  logic [31:0] vectornum, errors;

endmodule

`default_nettype wire
