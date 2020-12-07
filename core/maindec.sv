`default_nettype none

module maindec(input  wire logic       clk, rstn,
               input  wire logic [6:0] op,
               output logic            pcwrite, memwrite,
                                       irwrite, regwrite, pcbufwrite,
               output logic            iord,
               output logic      [1:0] alusrca, alusrcb, regsrc, pcsrc,
               output logic            branch,
               output logic      [2:0] aluop);

  // TODO: Vivado で合成可能...?
  typedef enum logic [3:0] {FETCH, DECODE, MEMADR, MEMREAD, MEMWRITEBACK,
                            MEMWRITE, EXECUTE, ALUWRITEBACK, BRANCH,
                            IMMEXECUTE, IMMWRITEBACK, LUIEX, AUIPCEX,
                            JALEX, JALREX} statetype;
  statetype state, nextstate;

  parameter RTYPE = 7'b0110011;
  parameter ITYPE = 7'b0010011;
  parameter BTYPE = 7'b1100011;
  parameter LUI   = 7'b0110111;
  parameter AUIPC = 7'b0010111;
  parameter JAL   = 7'b1101111;
  parameter JALR  = 7'b1100111;
  parameter LW    = 7'b0000011;
  parameter SW    = 7'b0100011;

  logic [17:0] controls;

  // state register
  always_ff @(posedge clk)
    if(~rstn)  state <= FETCH;
    else       state <= nextstate;

  // next state logic
  always_comb
    case(state)
      FETCH:        nextstate = DECODE;
      DECODE:       case(op)
                      LW:       nextstate = MEMADR;
                      SW:       nextstate = MEMADR;
                      RTYPE:    nextstate = EXECUTE;
                      BTYPE:    nextstate = BRANCH;
                      ITYPE:    nextstate = IMMEXECUTE;
                      LUI:      nextstate = LUIEX;
                      AUIPC:    nextstate = AUIPCEX;
                      JAL:      nextstate = JALEX;
                      JALR:     nextstate = JALREX;
                      default:  nextstate = FETCH;   // should never happen
                    endcase
      MEMADR:       case(op)
                      LW:       nextstate = MEMREAD;
                      SW:       nextstate = MEMWRITE;
                      default:  nextstate = FETCH;   // should never happen
                    endcase
      MEMREAD:      nextstate = MEMWRITEBACK;
      MEMWRITEBACK: nextstate = FETCH;
      MEMWRITE:     nextstate = FETCH;
      EXECUTE:      nextstate = ALUWRITEBACK;
      ALUWRITEBACK: nextstate = FETCH;
      BRANCH:       nextstate = FETCH;
      IMMEXECUTE:   nextstate = IMMWRITEBACK;
      IMMWRITEBACK: nextstate = FETCH;
      LUIEX:        nextstate = FETCH;
      AUIPCEX:      nextstate = FETCH;
      JALEX:        nextstate = FETCH;
      JALREX:       nextstate = FETCH;
      default:      nextstate = FETCH;   // should never happen
    endcase

  // output logic
  assign {pcwrite, memwrite, irwrite, regwrite, pcbufwrite, // 5bit
          iord,                                             // 1bit
          alusrca, alusrcb, regsrc, pcsrc,                  // 8bit
          branch,                                           // 1bit
          aluop} = controls;                                // 3bit

  always_comb
    case(state)
      FETCH:        controls = 18'b10101_0_00_01_00_00_0_000;
      DECODE:       controls = 18'b00000_0_01_10_00_00_0_000;
      MEMADR:       controls = 18'b00000_0_10_10_00_00_0_000;
      MEMREAD:      controls = 18'b00000_1_00_00_00_00_0_000;
      MEMWRITEBACK: controls = 18'b00010_0_00_00_01_00_0_000;
      MEMWRITE:     controls = 18'b01000_1_00_00_00_00_0_000;
      EXECUTE:      controls = 18'b00000_0_10_00_00_00_0_100;
      ALUWRITEBACK: controls = 18'b00010_0_00_00_00_00_0_000;
      BRANCH:       controls = 18'b00000_0_10_00_00_01_1_111;
      IMMEXECUTE:   controls = 18'b00000_0_10_10_00_00_0_101;
      IMMWRITEBACK: controls = 18'b00010_0_00_00_00_00_0_000;
      LUIEX:        controls = 18'b00010_0_00_00_10_00_0_000;
      AUIPCEX:      controls = 18'b00010_0_00_00_00_00_0_000;
      JALEX:        controls = 18'b10000_0_00_00_11_01_0_000;
      JALREX:       controls = 18'b10010_0_10_10_11_10_0_000;
      default:      controls = 18'b00000_x_xx_xx_xx_xx_x_xxx;  // should never happen
    endcase

endmodule

`default_nettype wire
