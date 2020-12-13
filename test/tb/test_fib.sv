`default_nettype none

module test_fib();

  // Inputs
  logic clk, rstn;

  // Instanciate the Device Under Test (DUT)
  test_top dut(clk, rstn);

  // generate clock
  always
  begin
    clk <= 1;
    #5;
    clk <= 0;
    #5;
  end

  // generate reset
  initial
  begin
    rstn <= 0;
    #30;
    rstn <= 1;
  end

endmodule

`default_nettype wire
