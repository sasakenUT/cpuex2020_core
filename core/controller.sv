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
                  output logic            rors, uart_go);

  logic [2:0] aluop;
  logic       branch, pcwrite, taken;

  // Main Decoder, ALU Decoder, and Branch Unit subunits.
  maindec md(clk, rstn, op,
             pcwrite, memwrite, irwrite, regwrite, pcbufwrite,
             iord,
             alusrca, alusrcb,
             regsrc,
             pcsrc,
             branch,
             aluop,
             uart_done,
             rors, uart_go);

  aludec  ad(funct3, funct7, aluop, alucontrol);

  branch_unit bu(branch, funct3, zero, taken);

  assign pcen = pcwrite | taken;

endmodule

`default_nettype wire
