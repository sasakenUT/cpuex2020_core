`default_nettype none

module fpudec(input  wire logic [2:0] funct3,
              input  wire logic [6:0] funct7,
              output logic      [3:0] fpucontrol,
              output logic            fpusrca, mode, fregwb);

  parameter FADD   = 7'b0000000;
  parameter FSUB   = 7'b0000100;
  parameter FMUL   = 7'b0001000;
  parameter FDIV   = 7'b0001100;
  parameter FSQRT  = 7'b0101100;
  parameter FCVTWS = 7'b1100000;  // ftoi
  parameter FCMP   = 7'b1010000;  // FEQ, FLT, FLE
  parameter FCVTSW = 7'b1101000;  // itof

  parameter FEQ = 3'b010;
  parameter FLT = 3'b001;
  parameter FLE = 3'b000;

  assign fpusrca = (funct7 == FCVTSW);
  assign mode    = (funct7 == FCVTWS) && (funct3 == 3'b010);
  assign fregwb  = (funct7 == FCMP) || (funct7 == FCVTWS);

  always_comb
    case(funct7)
      FADD:     fpucontrol = 4'b0000;
      FSUB:     fpucontrol = 4'b0001;
      FMUL:     fpucontrol = 4'b0010;
      FDIV:     fpucontrol = 4'b0011;
      FSQRT:    fpucontrol = 4'b0100;
      FCVTWS:   fpucontrol = 4'b0101;
      FCMP:     case(funct3)
                  FEQ:  fpucontrol = 4'b0110;
                  FLT:  fpucontrol = 4'b0111;
                  FLE:  fpucontrol = 4'b1000;
                  default:  fpucontrol = 4'b0000;   // should never happen
                endcase
      FCVTSW:   fpucontrol = 4'b1001;
      default:  fpucontrol = 4'b0000;   // should never happen
    endcase

endmodule

`default_nettype wire
