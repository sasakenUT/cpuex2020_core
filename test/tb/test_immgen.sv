`timescale 1ns / 1ps
`default_nettype none

module test_immgen();

  // Input
  logic [31:0] instr;

  // Output
  logic [31:0] imm;

  // Internal signals
  reg clk;

  // Simulation variables
  logic [31:0] vectornum, errors;
  logic [63:0] testvectors[99:0];
  logic [31:0] ExpectedImm;

  // Instantiate the Unit Under Test (UUT)
  immgen uut(instr, imm);

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
      $readmemh("test_immgen.tv", testvectors);
      vectornum = 0; errors = 0;
    end

  // apply testvectors on rising edge of clk
  always @(posedge clk)
    begin
      #1;
      {instr, ExpectedImm} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    begin
      if (imm !== ExpectedImm)
        begin
          $display("Error: input: instr = %h(hex)", instr);
          $display("  imm = %h(hex)\n  (ExpectedImm = %h(hex))", imm, ExpectedImm);
          errors = errors + 1;
        end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 64'hx)
        begin
          $display("%d test completed with %d errors", vectornum, errors);
          $finish;
        end
    end

endmodule

`default_nettype wire
