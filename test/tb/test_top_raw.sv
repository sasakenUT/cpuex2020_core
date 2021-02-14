`timescale 1ns / 1ps
`default_nettype none

module test_top_tb();

  // Input output signals
  logic clk, rstn, txd, rxd;

  // Instanciate units
  top uut(clk, rstn, txd, rxd);

  // generate clock
  always
  begin
    clk <= 1;
    #5;
    clk <= 0;
    #5;
  end

  initial
  begin
    rstn <= 0;
    #100;
    rstn <= 1;
  end

endmodule

`default_nettype wire
