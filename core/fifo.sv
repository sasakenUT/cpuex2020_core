`default_nettype none

module fifo(input  wire logic [7:0] indata,
            output logic      [7:0] outdata,
            input  wire             push, pop,
            output logic            empty,
            input  wire logic       clk, rstn);

  // size 8 x 2048 buffer
  logic [7:0]  buffer[2047:0];
  logic [10:0] head, tail;

  assign empty = (head == tail);
  assign outdata = buffer[head];

  always @(posedge clk) begin
    if (~rstn) begin
      head <= 11'b0;
      tail <= 11'b0;
      buffer[0] <= 8'b0;
    end else begin
      if (push) begin
        buffer[tail] <= indata;
        tail  <= tail + 11'b1;
      end
      if (pop) begin
        head  <= head + 11'b1;
      end
    end
  end

endmodule

`default_nettype wire
