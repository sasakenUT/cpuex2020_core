`timescale 1ns / 1ps
`default_nettype none

module test_alu_v();

  // Inputs
  logic [31:0] A;
  logic [31:0] B;
  logic [4:0] F;

  // Outputs
  logic [31:0] Y;
  logic Zero;

  // Internal signals
  reg clk;

  // Simulation variables
  logic [31:0] vectornum, errors;
  logic [101:0] testvectors[100:0];
  logic [31:0] ExpectedY;
  logic        ExpectedZero;

  // Instantiate the Unit Under Test (UUT)
  alu uut(A, B, F, Y, Zero);

  // generate clock
  always
    begin
      clk = 1;
      #5;
      clk = 0;
      #5;
    end

  // at start of test, load vectors
  initial
    begin
      $readmemh("test_alu.tv", testvectors);
      vectornum = 0; errors = 0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1;
      {ExpectedZero, F, A, B, ExpectedY} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    begin
      if ({Y, Zero} !== {ExpectedY, ExpectedZero})
        begin
          $display("Error: inputs: F = %h(hex), A = %h(hex), B = %h(hex)", F, A, B);
          $display("  Y = %h(hex), Zero = %b, \n (Expected Y = %h(hex), Expected Zero = %b)", Y, Zero, ExpectedY, ExpectedZero);
          errors = errors + 1;
        end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 102'hx)
        begin
          $display("%d tests completed with %d errors", vectornum, errors);
          $finish;
        end
    end

endmodule

`default_nettype wire
