`default_nettype none

module flptdec(input  wire logic       clk, rstn,
               input  wire logic [6:0] op,
               input  wire logic [6:0] funct7,
               output logic            fregwrite_f, regwrite_f,
               output logic      [1:0] fregsrc_f,
               output logic      [2:0] regsrc_f,
               input wire logic        indecode, fpu_valid, fregwb,
               output logic            flpt_done, fpu_go);

  typedef enum logic [2:0] {F_DECODE, FSGN_EX, FMV_X_W_EX, FMV_W_X_EX,
                            FPU_GO, FPU_WAIT, IREG_WB, FREG_WB} statetype;
  statetype state, nextstate;

  // F-type op
  parameter FTYPE  = 7'b1010011;

  // function7 code
  parameter FSGN   = 7'b0010000;
  parameter FMVXW  = 7'b1110000;  // ireg <- freg
  parameter FMVWX  = 7'b1111000;  // freg <- ireg

  logic [8:0] controls;
  logic       ok;

  assign ok = indecode && (op == FTYPE);

  // state register
  always_ff @(posedge clk)
    if(~rstn)  state <= F_DECODE;
    else       state <= nextstate;

  // next state logic
  always_comb
    case(state)
      F_DECODE:   nextstate = ok ? ((funct7 == FSGN)  ? FSGN_EX :
                                    (funct7 == FMVXW) ? FMV_X_W_EX :
                                    (funct7 == FMVWX) ? FMV_W_X_EX :
                                    FPU_GO) : F_DECODE;
      FSGN_EX:    nextstate = F_DECODE;
      FMV_X_W_EX: nextstate = F_DECODE;
      FMV_W_X_EX: nextstate = F_DECODE;
      FPU_GO:     nextstate = FPU_WAIT;
      FPU_WAIT:   nextstate = fpu_valid ? (fregwb ? IREG_WB : FREG_WB) : FPU_WAIT;
      IREG_WB:    nextstate = F_DECODE;
      FREG_WB:    nextstate = F_DECODE;
      default:    nextstate = F_DECODE;   // should never happen
    endcase

  // output logic
  assign {fregwrite_f, regwrite_f,        // 2bit
          fregsrc_f,                      // 2bit
          regsrc_f,                       // 3bit
          flpt_done, fpu_go} = controls;  // 2bit

  always_comb
    case(state)
      F_DECODE:   controls = 9'b00_00_000_00;
      FSGN_EX:    controls = 9'b10_01_000_10;
      FMV_X_W_EX: controls = 9'b01_00_101_10;
      FMV_W_X_EX: controls = 9'b10_10_000_10;
      FPU_GO:     controls = 9'b00_00_000_01;
      FPU_WAIT:   controls = 9'b00_00_000_00;
      IREG_WB:    controls = 9'b01_00_110_10;
      FREG_WB:    controls = 9'b10_11_000_10;
      default:    controls = 9'b00_00_000_00;
    endcase

endmodule

`default_nettype wire
