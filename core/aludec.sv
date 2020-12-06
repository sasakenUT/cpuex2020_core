`default_nettype none

module aludec(input  wire logic [2:0] funct3,
              input  wire logic [6:0] funct7,
              input  wire logic [2:0] aluop,
              output logic      [4:0] alucontrol);

  // TODO: non-blocking or blocking ... ?
  // TODO: (case, endcase), default, number check
  always_comb
    case(aluop)
      3'b000: alucontrol <= 5'b00011;   // add
      3'b001: alucontrol <= 5'b10011;   // subtract
      3'b100: case(funct3)
                3'b000: case(funct7)
                          7'b0000000: alucontrol <= 5'b10011;
                          7'b0100000: alucontrol <= 5'b00011;
                          default:    alucontrol <= 5'bxxxxx;   // should never happen
                        endcase
                3'b001: alucontrol <= 5'b00110;   // sll
                3'b010: alucontrol <= 5'b10100;   // slt
                3'b011: alucontrol <= 5'b10101;   // sltu
                3'b100: alucontrol <= 5'b00010;   // xor
                3'b101: case(funct7)
                          7'b0000000: alucontrol <= 5'b00111;   // srl
                          7'b0100000: alucontrol <= 5'b01000;   // sra
                          default:    alucontrol <= 5'bxxxxx;   // should never happen
                        endcase
                3'b110: alucontrol <= 5'b00001;   // or
                3'b111: alucontrol <= 5'b00000;   // and
                default: alucontrol <= 5'bxxxxx;  // should never happen
              endcase
      3'b101: case(funct3)
                3'b000: alucontrol <= 5'b00011;   // add
                3'b010: alucontrol <= 5'b10100;   // slt
                3'b011: alucontrol <= 5'b10101;   // sltu
                3'b100: alucontrol <= 5'b00010;   // xor
                3'b110: alucontrol <= 5'b00001;   // or
                3'b111: alucontrol <= 5'b00000;   // and
                3'b001: alucontrol <= 5'b00110;   // sll
                3'b101: case(funct7)
                          7'b0000000: alucontrol <= 5'b00111;   // srl
                          7'b0100000: alucontrol <= 5'b01000;   // sra
                          default:    alucontrol <= 5'bxxxxx;
                        endcase
                default: alucontrol <= 5'bxxxxx;  // should never happen
              endcase
      3'b110: case(funct3)
                3'b000: alucontrol <= 5'b01001;   // mul
                3'b001: alucontrol <= 5'b01010;   // mulh
                default: alucontrol <= 5'bxxxxx;  // should never happen
              endcase
      3'b111: case(funct3)
                3'b000: alucontrol <= 5'b10011;   // subtract
                3'b001: alucontrol <= 5'b10011;   // subtract
                3'b100: alucontrol <= 5'b10100;   // slt
                3'b101: alucontrol <= 5'b10100;   // slt
                3'b110: alucontrol <= 5'b10101;   // sltu
                3'b111: alucontrol <= 5'b10101;   // sltu
                default: alucontrol <= 5'bxxxxx;  // should never happen
              endcase
      default: alucontrol <= 5'bxxxxx;    // should never happen
    endcase

endmodule

`default_nettype wire
