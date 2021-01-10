`default_nettype none

module riscv(input  wire logic        clk, rstn,
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

  controller c(clk, rstn,
               op, funct3, funct7, zero,
               pcen, memwrite, irwrite, regwrite, pcbufwrite,
               iord,
               alusrca, alusrcb,
               regsrc,
               pcsrc,
               alucontrol,
               uart_done, rors, uart_go);

  uart_unit  u(clk, rstn,
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
               rxdata, txdata);

endmodule

`default_nettype wire
