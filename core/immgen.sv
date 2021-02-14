`default_nettype none

module immgen(input wire logic [31:0] instr,
              output logic     [31:0] imm);

  logic [6:0] op;

  assign op = instr[6:0];

  always_comb
    case (op)
      7'b0010011: imm = {{20{instr[31]}}, instr[31:20]};  // OP-IMM
      7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};  // OP-BRANCH
      7'b0110111: imm = {instr[31:12], 12'b0};  // LUI
      7'b0010111: imm = {instr[31:12], 12'b0};  // AUIPC
      7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};  // JAL
      7'b1100111: imm = {{20{instr[31]}}, instr[31:20]};  // JALR
      7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};  // LW
      7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // SW
      7'b0000111: imm = {{20{instr[31]}}, instr[31:20]};  // FLW
      7'b0100111: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // FSW
      default:    imm = 32'b0;  // other instruction
    endcase

endmodule

`default_nettype wire
