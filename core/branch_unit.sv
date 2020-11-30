`default_nettype none

module branch_unit(input wire logic       branch,
                   input wire logic [2:0] funct3,
                   input wire logic       zero,
                   output logic           taken);

  always_comb
    case (funct3)
      3'b000: taken = branch & zero;    // BEQ
      3'b001: taken = branch & (~zero); // BNE
      3'b100: taken = branch & (~zero); // BLT
      3'b101: taken = branch & zero;    // BGE
      3'b110: taken = branch & (~zero); // BLTU
      3'b111: taken = branch & zero;    // BGEU
      default: taken = 1'b0;            // default should never happen
    endcase

endmodule

`default_nettype wire
