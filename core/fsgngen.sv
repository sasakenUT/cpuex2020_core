`default_nettype

module fsgngen(input  wire logic [31:0] a, b,
               input  wire logic [2:0]  funct3,
               output logic      [31:0] c);

  always_comb
    case (funct3)
      3'b000: c = {b[31],  a[30:0]};  // FSGNJ
      3'b001: c = {~b[31], a[30:0]};  // FSGNJN
      default: c = 32'b0;             // other instruction
    endcase

endmodule

`default_nettype
