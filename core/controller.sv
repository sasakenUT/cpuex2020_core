`default_nettype none

module controller(input  wire logic       clk, rstn,
                  input  wire logic [6:0] op,
                  input  wire logic [2:0] funct3,
                  input  wire logic [6:0] funct7,
                  input  wire logic       zero,
                  output logic            pcen, memwrite,
                                          irwrite, regwrite, pcbufwrite,
                  output logic            iord,
                  output logic      [1:0] alusrca, alusrcb,
                  output logic      [2:0] regsrc,
                  output logic      [1:0] pcsrc,
                  output logic      [4:0] alucontrol,
                  input  wire logic       uart_done,
                  output logic            rors, uart_go,
                  output logic            iorf, fregwrite,
                  output logic      [1:0] fregsrc,
                  output logic            fpusrca,
                  output logic      [3:0] fpucontrol,
                  output logic            mode, fpu_go,
                  input  wire logic       fpu_valid);

  logic [2:0] aluop;
  logic       branch, pcwrite, taken;
  logic       fregwrite_i, fregwrite_f, regwrite_i, regwrite_f;
  logic [2:0] regsrc_i, regsrc_f;
  logic [1:0] fregsrc_i, fregsrc_f;
  logic       fregwb, indecode, flpt_done;

  // Main Decoder, ALU Decoder, FLPt Decoder, FPU Decoder and Branch Unit subunits.
  maindec md(clk, rstn, op,
             pcwrite, memwrite, irwrite, regwrite_i, pcbufwrite,
             iord,
             alusrca, alusrcb,
             regsrc_i,
             pcsrc,
             branch,
             aluop,
             uart_done,
             rors, uart_go,
             iorf, fregwrite_i,
             fregsrc_i,
             indecode, flpt_done);

  aludec  ad(funct3, funct7, aluop, alucontrol);

  branch_unit bu(branch, funct3, zero, taken);

  flptdec fld(clk, rstn, op, funct7,
              fregwrite_f, regwrite_f, fregsrc_f, regsrc_f,
              indecode, fpu_valid, fregwb,
              flpt_done, fpu_go);

  fpudec  fd(funct3, funct7, fpucontrol, fpusrca, mode, fregwb);

  assign pcen = pcwrite | taken;
  assign regwrite = regwrite_i | regwrite_f;
  assign regsrc = regsrc_i | regsrc_f;
  assign fregwrite = fregwrite_i | fregwrite_f;
  assign fregsrc = fregsrc_i | fregsrc_f;

endmodule

`default_nettype wire
