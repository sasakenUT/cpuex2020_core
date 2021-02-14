`default_nettype none

module uart_unit #(CLK_PER_HALF_BIT = 434) (
                 input  wire logic       clk, rstn,
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
  logic [7:0] rdata, outdata;
  logic [2:0] controls;
  logic       accept, empty;

  // Instanciate uart_tx, uart_rx, and fifo
  uart_tx #(CLK_PER_HALF_BIT) tx(txdata, tx_start, tx_busy, txd, clk, rstn);
  uart_rx #(CLK_PER_HALF_BIT) rx(rdata,  rx_ready, ferr, rxd, clk, rstn);
  fifo fifo(rdata, outdata, rx_ready, accept, empty, clk, rstn);

  // set recv data
  always_ff @(posedge clk)
    if (accept) rxdata <= outdata;

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
      RECV_WAIT:    nextstate = ~empty ? RECV_DONE : RECV_WAIT;
      RECV_DONE:    nextstate = IDLE;
      default:      nextstate = IDLE;   // should never happen
    endcase


  // control logic
  assign {uart_done, tx_start, accept} = controls;

  always_comb
    case(state)
      IDLE:         controls = 3'b000;
      SEND_GO:      controls = 3'b010;
      SEND_WAIT:    controls = 3'b000;
      SEND_DONE:    controls = 3'b100;
      RECV_WAIT:    controls = 3'b000;
      RECV_DONE:    controls = 3'b101;
      default:      controls = 3'b000;
    endcase

endmodule

`default_nettype wire
