/*
*   dummy units for test
*/
`default_nettype none

module uart_tx(input  wire logic [7:0] txdata,
               input  wire logic       tx_start,
               output logic            tx_busy,
               output logic            txd,
               input  wire logic       clk, rstn);

  logic [31:0] counter;

  always_ff @(posedge clk) begin
    if (~rstn) begin
      tx_busy <= 1'b0;
      txd     <= 1'b0;
      counter <= 0;
    end else begin
      if (tx_start) begin
          tx_busy <= 1'b1;
      end
      if (tx_busy) begin
          counter  <= counter + 1;
      end
      if (counter > 19) begin
          tx_busy <= 1'b0;
          counter <= 0;
      end
    end
  end

endmodule


module uart_rx(output logic      [7:0] rdata,
               output logic            rx_ready,
               output logic            ferr,
               input  wire logic       rxd,
               input  wire             clk, rstn);

  logic [31:0] counter;

  always_ff @(posedge clk) begin
    if (~rstn) begin
      rx_ready <= 1'b0;
      counter  <= 0;
      ferr     <= 1'b0;
    end else begin
        counter <= counter + 1;

        if (counter > 30) begin
            rx_ready <= 1'b1;
        end
        if (rx_ready) begin
            rx_ready <= 1'b0;
            counter  <= 0;
            rdata    <= 8'b10101010;
        end
    end
  end

endmodule

`default_nettype wire
