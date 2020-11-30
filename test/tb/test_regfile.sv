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

  // Instantiate the Unit Under Test (UUT)
  regfile rg(clk, we3, ra1, ra2, wa3, wd3, rd1, rd2);

  // generate clock
  always
  begin
    clk <= 1;   // Non-Blocking ...?
    #5;
    clk <= 0;
    #5;
  end

  // generate write enable signal pattern
  always
  begin
    we3 <= 1;
    #10;
    we3 <= 0;
    #10;
  end

  // Read address, write address, and write data pattern
  initial
  begin
    ra1 <= 5'd0;
    ra2 <= 5'd1;
    wa3 <= 5'd1;
    wd3 <= 32'hffffffff;
    #10;
    wd3 <= 32'heeeeeeee;
    #10;
    ra2 <= 5'd2;
    wa3 <= 5'd0;
    wd3 <= 32'hdddddddd;
    #10;
    $finish;
  end

endmodule

`default_nettype wire
