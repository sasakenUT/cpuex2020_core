`default_nettype none

module alu(input  wire logic [31:0] A, B,   // input should be wire logic to pass vivado synsthesis
           input  wire logic [4:0]  F,
           output logic      [31:0] Y,
           output logic             Zero);

  logic [31:0] S, Bout;
  logic [4:0]  shamt;
  logic        Cout;
  logic [63:0] M;

  assign Bout = F[4] ? ~B : B;
  assign shamt = Bout[4:0];
  assign {Cout, S} = A + Bout + F[4];
  assign M = $signed(A) * $signed(Bout);

  always_comb
    case (F[3:0])
      4'b0000: Y = A & Bout;
      4'b0001: Y = A | Bout;
      4'b0010: Y = A ^ Bout;
      4'b0011: Y = S;
      4'b0100: Y = {31'b0, S[31]};
      4'b0101: Y = {31'b0, ~Cout};
      4'b0110: Y = A << shamt;
      4'b0111: Y = A >> shamt;
      4'b1000: Y = $signed(A) >>> shamt;
      4'b1001: Y = M[31:0];
      4'b1010: Y = M[63:32];
      default: Y = 32'b0;  // default should never happen
    endcase

  assign Zero = (Y == 32'b0);

endmodule

`default_nettype wire
