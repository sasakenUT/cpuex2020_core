`default_nettype none

module riscv #(CLK_PER_HALF_BIT = 434) (
             input  wire logic        clk, rstn,
             output logic      [31:0] adr, writedata,
             output logic             memwrite,
             input  wire logic [31:0] readdata,
             output wire              txd,
             input  wire logic        rxd);

  logic       pcen, irwrite, regwrite, pcbufwrite;
  logic       iord;
  logic [1:0] alusrca, alusrcb;
  logic [2:0] regsrc;
  logic [1:0] pcsrc;
  logic [4:0] alucontrol;

  logic [6:0] op;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic       zero;

  logic       uart_done, rors, uart_go;
  logic [7:0] rxdata;
  logic [7:0] txdata;

  logic       iorf, fregwrite;
  logic [1:0] fregsrc;
  logic       fpusrca;
  logic [3:0] fpucontrol;
  logic       mode, fpu_go, fpu_valid;
  logic [24:0] rest_instr;

  controller c(clk, rstn,
               op, funct3, funct7, zero,
               pcen, memwrite, irwrite, regwrite, pcbufwrite,
               iord,
               alusrca, alusrcb,
               regsrc,
               pcsrc,
               alucontrol,
               uart_done, rors, uart_go,
               iorf, fregwrite,
               fregsrc,
               fpusrca,
               fpucontrol,
               mode, fpu_go, fpu_valid,
               rest_instr);

  uart_unit  #(CLK_PER_HALF_BIT) u(clk, rstn,
                                   uart_done,
                                   rors, uart_go,
                                   rxdata,
                                   txdata,
                                   txd, rxd);

  datapath  dp(clk, rstn,
               pcen, irwrite, regwrite, pcbufwrite,
               iord,
               alusrca, alusrcb, regsrc, pcsrc,
               alucontrol,
               op, funct3, funct7, zero,
               adr, writedata, readdata,
               rxdata, txdata,
               iorf, fregwrite,
               fregsrc, fpusrca,
               fpucontrol,
               mode, fpu_go, fpu_valid,
               rest_instr);

endmodule

`default_nettype wire
