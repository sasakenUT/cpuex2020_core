`default_nettype none

module datapath(input  wire logic        clk, rstn,
                input  wire logic        pcen, irwrite,
                                         regwrite, pcbufwrite,
                input  wire logic        iord,
                input  wire logic [1:0]  alusrca, alusrcb,
                input  wire logic [2:0]  regsrc,
                input  wire logic [1:0]  pcsrc,
                input  wire logic [4:0]  alucontrol,
                output logic      [6:0]  op,
                output logic      [2:0]  funct3,
                output logic      [6:0]  funct7,
                output logic             zero,
                output logic      [31:0] adr, writedata,
                input  wire logic [31:0] readdata,
                input  wire logic [7:0]  rxdata,
                output wire logic [7:0]  txdata,
                input  wire logic        iorf, fregwrite,
                input  wire logic [1:0]  fregsrc,
                input  wire logic        fpusrca,
                input  wire logic [3:0]  fpucontrol,
                input  wire logic        mode,
                input  wire logic        fpu_go,
                output logic             fpu_valid);

  // Internal signals of the datapath module
  logic [31:0] pcnext, pc, pcout;
  logic [31:0] instr, data;
  logic [31:0] wd3, rd1, rd2, ur3;
  logic [31:0] a, b;
  logic [31:0] imm, srca, srcb, aluresult, aluout;
  logic [31:0] jalrpc;

  logic [31:0] fwd3, frd1, frd2;
  logic [31:0] fa, fb;
  logic [31:0] fsgnres, fsrca, fpuresult, fpuout;

  assign op     = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];
  assign txdata = a[7:0];

  // datapath
  // program counter
  flopenr pcreg(clk, rstn, pcen, pcnext, pc);
  mux2    adrmux(pc, aluout, iord, adr);

  // memory
  mux2    wdmux(b, fb, iorf, writedata);

  flopenr instrreg(clk, rstn, irwrite, readdata, instr);
  flopr   datareg(clk, rstn, readdata, data);

  // int register file, data buffer
  mux7    wd3mux(aluout, data, imm, pc, {ur3[31:8], rxdata}, fa, fpuout, regsrc, wd3);
  regfile irf(clk, regwrite, instr[19:15], instr[24:20], instr[11:7], wd3, rd1, rd2, ur3);
  immgen  ig(instr, imm);

  flopenr curpcreg(clk, rstn, pcbufwrite, pc, pcout);   // current pc register
  flopr   areg(clk, rstn, rd1, a);
  flopr   breg(clk, rstn, rd2, b);

  // ALU inputs, ALU, ALU outputs
  mux3    srcamux(pc, pcout, a, alusrca, srca);
  mux3    srcbmux(b, 32'b100, imm, alusrcb, srcb);

  alu     alu(srca, srcb, alucontrol, aluresult, zero);

  flopr   alureg(clk, rstn, aluresult, aluout);
  setlsb0 slsb0(aluresult, jalrpc);

  // pc source
  mux3    pcmux(aluresult, aluout, jalrpc, pcsrc, pcnext);

  // float register file, data buffer
  fsgngen fg(fa, fb, funct3, fsgnres);
  mux4    fwdmux(data, fsgnres, a, fpuout, fregsrc, fwd3);
  fregfile frf(clk, fregwrite, instr[19:15], instr[24:20], instr[11:7], fwd3, frd1, frd2);

  flopr   fareg(clk, rstn, frd1, fa);
  flopr   fbreg(clk, rstn, frd2, fb);

  // FPU inputs, FPU, FPU outputs
  mux2    fsrcamux(fa, a, fpusrca, fsrca);

  fpu     fpu(fsrca, fb, fpuresult, fpu_go, fpucontrol, mode, fpu_valid, clk);

  flopr   fpureg(clk, rstn, fpuresult, fpuout);

endmodule

`default_nettype wire
