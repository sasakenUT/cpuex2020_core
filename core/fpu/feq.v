module feq(
  input wire[31:0]    a,
  input wire[31:0]    b,
  input wire          en,
  input wire          clk,
  output reg[31:0]   c,
  output reg         ready
);

  wire zero;
  wire res;

  assign zero = (|a[30:23] == 1'b0 && |b[30:23] == 1'b0) ? 1'b1 : 1'b0;

  assign res = 
    (zero == 1'b1) ? 1'b1 :       // a and b are both zero
    a == b ? 1'b1 : 1'b0;

  always @(posedge clk) begin
    c <= {31'b0, res};
    ready <= en;
  end

endmodule
