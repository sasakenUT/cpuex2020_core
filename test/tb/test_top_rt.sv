`timescale 1ns / 1ps
`default_nettype none

module test_top_tb();

  // Input output signals
  logic clk, rstn, txd, rxd;

  // Internal signals
  logic [7:0] indata, outdata;
  logic       tx_start, tx_busy, rready, ferr;
  logic [7:0] sld_in[1299:0];
  logic       send_go;
  logic [10:0] srv_cnt;

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

  // send from server
  assign indata = sld_in[srv_cnt];

  always @(posedge clk)
  begin
    if (~rstn) begin
      send_go  <= 1'b0;
      send_end <= 1'b0;
      srv_cnt  <= 11'b0;
    end else begin
      if (outdata == 8'haa) begin
        send_go <= 1'b1;
      end

      if (srv_cnt > 1299) begin
        send_end <= 1'b1;
      end

      if (~send_end && send_go) begin
        if (~tx_busy) begin
          tx_start <= 1'b1;
          srv_cnt  <= srv_cnt + 11'b1;
        end
        if (tx_start) begin
          tx_start <= 1'b0;
        end
      end
    end
  end

  // set raytrace input to sld_in
  initial
  begin
    $readmemh("sld_byte.mem", sld_in, 0, 1299);
  end

  initial
  begin
    rstn <= 0;
    #100;
    tx_start <= 0;
    rstn <= 1;
  end

endmodule

`default_nettype wire
