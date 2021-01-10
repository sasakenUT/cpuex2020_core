`default_nettype none

module uart_unit(input  wire logic       clk, rstn,
                 output logic            uart_done,
                 input  wire logic       rors, uart_go,
                 output logic      [7:0] rxdata,
                 input  wire logic [7:0] txdata,
                 output logic            txd,
                 input  wire logic       rxd);

  typedef enum logic [2:0] {IDLE, SEND_GO, SEND_WAIT, SEND_DONE,
                            RECV_WAIT, RECV_DONE} statetype;
  statetype state, nextstate;

  logic       tx_start, tx_busy, rx_ready, ferr;
  logic [7:0] rdata;
  logic       data_valid;
  logic [1:0] controls;

  // Instanciate uart_tx, and uart_rx
  uart_tx tx(txdata, tx_start, tx_busy, txd, clk, rstn);
  uart_rx rx(rdata,  rx_ready, ferr, rxd, clk, rstn);


  // recv state
  always_ff @(posedge clk) begin
    if(~rstn) begin
      rxdata     <= 8'b0;
      data_valid <= 1'b0;
    end else begin
      if (rx_ready) begin
        rxdata     <= rdata;
        data_valid <= 1'b1;
      end
      if (data_valid) begin
        data_valid <= 1'b0;
      end
    end
  end


  // state register
  always_ff @(posedge clk)
    if(~rstn)  state <= IDLE;
    else       state <= nextstate;

  // next state logic
  always_comb
    case(state)
      IDLE:         nextstate = uart_go ? (rors ? SEND_GO : RECV_WAIT) : IDLE;
      SEND_GO:      nextstate = SEND_WAIT;
      SEND_WAIT:    nextstate = tx_busy ? SEND_WAIT : SEND_DONE;
      SEND_DONE:    nextstate = IDLE;
      RECV_WAIT:    nextstate = data_valid ? RECV_DONE : RECV_WAIT;
      RECV_DONE:    nextstate = IDLE;
      default:      nextstate = IDLE;   // should never happen
    endcase


  // control logic
  assign {uart_done, tx_start} = controls;

  always_comb
    case(state)
      IDLE:         controls = 2'b00;
      SEND_GO:      controls = 2'b01;
      SEND_WAIT:    controls = 2'b00;
      SEND_DONE:    controls = 2'b10;
      RECV_WAIT:    controls = 2'b00;
      RECV_DONE:    controls = 2'b10;
      default:      controls = 2'b00;
    endcase

endmodule

`default_nettype wire
