`timescale 1ns / 1ps
`default_nettype none

module test_alu_v();

  // Inputs
  logic [31:0] A;
  logic [31:0] B;
  logic [2:0] F;

  // Outputs
  logic [31:0] Y;
  logic Zero;

  // Internal signals
  reg clk;

  // Simulation variables
  logic [31:0] vectornum, errors;
  logic [99:0] testvectors[10000:0];
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
          $display("Error: inputs: F = %h, A = %h, B = %h", F, A, B);
          $display("  Y = %h, Zero = %b, \n
                    (Expected Y = %h, Expected Zero = %h", Y, Zero, ExpectedY, ExpectedZero);
          errors = errors + 1;
        end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] == 101'hx)
        begin
          $display("%d tests completed with %d errors", vectornum, errors);
          $finish
        end
    end

endmodule

`default_nettype wire
