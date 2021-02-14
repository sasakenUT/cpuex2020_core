// less or equal
module fle(
  input wire[31:0]    a,
  input wire[31:0]    b,
  input wire          en,
  input wire          clk,
  output reg[31:0]   c,
  output reg         ready
);

  wire exp_eq;
  wire exp_cmp;
  wire man_cmp;
  wire sign_xor;
  wire zero;
  wire res;

  assign exp_eq = (a[30:23] == b[30:23]) ? 1'b1 : 1'b0;
  assign exp_cmp = (a[30:23] < b[30:23]) ? 1'b1 : 1'b0;
  assign man_cmp = (a[22:0] <= b[22:0])? 1'b1 : 1'b0;
  assign sign_xor = a[31] ^ b[31];
  assign zero = (a[30:23] == 8'b0 && b[30:23] == 8'b0) ? 1'b1 : 1'b0;

  assign res = 
    (zero == 1'b1) ? 1'b1 :       // a and b are both zero
    (sign_xor == 1'b1) ? a[31] :  // a < 0 < b or b < 0 < a
    (exp_eq == 1'b1) ? man_cmp ^ a[31] :
    exp_cmp ^ a[31];

  always @(posedge clk) begin
    c <= {31'b0, res};
    ready <= en;
  end

endmodule
