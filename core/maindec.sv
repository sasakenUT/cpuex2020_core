`default_nettype none

module maindec(input  wire logic clk, rstn,
               input  wire logic [6:0] op,
               output logic            pcwrite, memwrite,
                                       irwrite, regwrite, pcbufwrite,
               output logic            iord,
               output logic      [1:0] alusrca, alusrcb, regsrc, pcsrc,
               output logic            branch,
               output logic      [2:0] aluop);

  // Vivado で合成可能...?
  typedef enum logic [3:0] {FETCH, DECODE, MEMADR, MEMREAD, MEMWRITEBACK,
                            MEMWRITE, EXECUTE, ALUWRITEBACK, BRANCH,
                            IMMEXECUTE, IMMWRITEBACK, LUIEX, AUIPCEX,
                            JALEX, JALREX} statetype;
  statetype [3:0] state, nextstate;

endmodule

`default_nettype wire
