`timescale 1ns / 1ps
`default_nettype none

module test_top_tb();

  // Input output signals
  logic clk, rstn, txd, rxd;

  // Internal signals
  logic [7:0] indata, outdata;
  logic       tx_start, tx_busy, rready, ferr;

  // uart parameter
  localparam CLK_PER_HALF_BIT = 434;

  // Instanciate units
  top uut(clk, rstn, txd, rxd);
  uart_tx #(CLK_PER_HALF_BIT) serv_tx(indata, tx_start, tx_busy, rxd, clk, rstn);   // server -> top
  uart_rx #(CLK_PER_HALF_BIT) serv_rx(outdata, rready, ferr, txd, clk, rstn);       // server <- top

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
    tx_start <= 0;
    rstn <= 1;
    indata <= 8'ha;
    #10;
    tx_start <= 1;
    #10;
    tx_start <= 0;
  end

endmodule

`default_nettype wire
