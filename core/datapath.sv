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
                output wire logic [7:0]  txdata);

  // Internal signals of the datapath module
  logic [31:0] pcnext, pc, pcout;
  logic [31:0] instr, data;
  logic [31:0] wd3, rd1, rd2;
  logic [31:0] a;
  logic [31:0] imm, srca, srcb, aluresult, aluout;
  logic [31:0] jalrpc;

  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];
  assign txdata = a[7:0];

  // datapath
  flopenr pcreg(clk, rstn, pcen, pcnext, pc);
  mux2    adrmux(pc, aluout, iord, adr);

  flopenr instrreg(clk, rstn, irwrite, readdata, instr);
  flopr   datareg(clk, rstn, readdata, data);

  mux5    wdmux(aluout, data, imm, pc, {24'b0, rxdata}, regsrc, wd3);
  regfile irf(clk, regwrite, instr[19:15], instr[24:20], instr[11:7], wd3, rd1, rd2);
  immgen  ig(instr, imm);

  flopenr curpcreg(clk, rstn, pcbufwrite, pc, pcout);
  flopr   areg(clk, rstn, rd1, a);
  flopr   breg(clk, rstn, rd2, writedata);

  mux3    srcamux(pc, pcout, a, alusrca, srca);
  mux3    srcbmux(writedata, 32'b100, imm, alusrcb, srcb);

  alu     alu(srca, srcb, alucontrol, aluresult, zero);

  flopr   alureg(clk, rstn, aluresult, aluout);
  setlsb0 slsb0(aluresult, jalrpc);

  mux3    pcmux(aluresult, aluout, jalrpc, pcsrc, pcnext);

endmodule

`default_nettype wire
