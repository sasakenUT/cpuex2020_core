`default_nettype none

module maindec(input  wire logic       clk, rstn,
               input  wire logic [6:0] op,
               output logic            pcwrite, memwrite,
                                       irwrite, regwrite, pcbufwrite,
               output logic            iord,
               output logic      [1:0] alusrca, alusrcb,
               output logic      [2:0] regsrc,
               output logic      [1:0] pcsrc,
               output logic            branch,
               output logic      [2:0] aluop,
               input  wire logic       uart_done,
               output logic            rors, uart_go,
               output logic            iorf, fregwrite_i,
               output logic      [1:0] fregsrc_i,
               output logic            indecode,
               input  wire logic       flpt_done);

  typedef enum logic [4:0] {FETCH, FETCHWAIT, FETCHVALID, DECODE, MEMADR,
                            MEMREAD, MEMREADWAIT, MEMREADVALID, MEMWRITEBACK,
                            MEMWRITE, EXECUTE, ALUWRITEBACK, BRANCH,
                            IMMEXECUTE, IMMWRITEBACK, LUIEX, AUIPCEX,
                            JALEX, JALREX, SENDB_GO, SENDB_WAIT, RECVB_GO,
                            RECVB_WAIT, RECVB_WRITE, FMEMWB, FMEMWRITE, FTEXECUTE} statetype;
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
  parameter RECVB = 7'b0000001;
  parameter SENDB = 7'b0000010;
  parameter FLW   = 7'b0000111;
  parameter FSW   = 7'b0100111;
  parameter FTYPE = 7'b1010011;

  logic [25:0] controls;

  // state register
  always_ff @(posedge clk)
    if(~rstn)  state <= FETCH;
    else       state <= nextstate;

  // next state logic
  always_comb
    case(state)
      FETCH:        nextstate = FETCHWAIT;
      FETCHWAIT:    nextstate = FETCHVALID;
      FETCHVALID:   nextstate = DECODE;
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
                      RECVB:    nextstate = RECVB_GO;
                      SENDB:    nextstate = SENDB_GO;
                      FTYPE:    nextstate = FTEXECUTE;
                      FLW:      nextstate = MEMADR;
                      FSW:      nextstate = MEMADR;
                      default:  nextstate = FETCH;   // should never happen
                    endcase
      MEMADR:       case(op)
                      LW:       nextstate = MEMREAD;
                      SW:       nextstate = MEMWRITE;
                      FSW:      nextstate = FMEMWRITE;
                      default:  nextstate = FETCH;   // should never happen
                    endcase
      MEMREAD:      nextstate = MEMREADWAIT;
      MEMREADWAIT:  nextstate = MEMREADVALID;
      MEMREADVALID: case(op)
                      FLW:      nextstate = FMEMWB;
                      default:  nextstate = MEMWRITEBACK;
                    endcase
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
      SENDB_GO:     nextstate = SENDB_WAIT;
      SENDB_WAIT:   case(uart_done)                 // busy wait until uart_done becomes 1
                      1'b1:     nextstate = FETCH;
                      1'b0:     nextstate = SENDB_WAIT;
                    endcase
      RECVB_GO:     nextstate = RECVB_WAIT;
      RECVB_WAIT:   case(uart_done)
                      1'b1:     nextstate = RECVB_WRITE;
                      1'b0:     nextstate = RECVB_WAIT;
                    endcase
      RECVB_WRITE:  nextstate = FETCH;
      FMEMWRITE:    nextstate = FETCH;
      FMEMWB:       nextstate = FETCH;
      FTEXECUTE:    nextstate = flpt_done ? FETCH : FTEXECUTE;    // busy wait until flpt_done becomes 1
      default:      nextstate = FETCH;   // should never happen
    endcase

  // output logic
  assign {pcwrite, memwrite, irwrite, regwrite, pcbufwrite, // 5bit
          iord,                                             // 1bit
          alusrca, alusrcb,                                 // 4bit
          regsrc,                                           // 3bit
          pcsrc,                                            // 2bit
          branch,                                           // 1bit
          aluop,                                            // 3bit
          rors, uart_go,                                    // 2bit
          iorf,                                             // 1bit
          fregwrite_i,                                      // 1bit
          fregsrc_i,                                        // 2bit
          indecode} = controls;                             // 1bit

  always_comb
    case(state)
      FETCH:        controls = 26'b10001_0_00_01_000_00_0_000_00_0_0_00_0;
      FETCHWAIT:    controls = 26'b00000_0_00_00_000_00_0_000_00_0_0_00_0;
      FETCHVALID:   controls = 26'b00100_0_00_00_000_00_0_000_00_0_0_00_0;
      DECODE:       controls = 26'b00000_0_01_10_000_00_0_000_00_0_0_00_1;
      MEMADR:       controls = 26'b00000_0_10_10_000_00_0_000_00_0_0_00_0;
      MEMREAD:      controls = 26'b00000_1_00_00_000_00_0_000_00_0_0_00_0;
      MEMREADWAIT:  controls = 26'b00000_1_00_00_000_00_0_000_00_0_0_00_0;
      MEMREADVALID: controls = 26'b00000_1_00_00_000_00_0_000_00_0_0_00_0;
      MEMWRITEBACK: controls = 26'b00010_0_00_00_001_00_0_000_00_0_0_00_0;
      MEMWRITE:     controls = 26'b01000_1_00_00_000_00_0_000_00_0_0_00_0;
      EXECUTE:      controls = 26'b00000_0_10_00_000_00_0_100_00_0_0_00_0;
      ALUWRITEBACK: controls = 26'b00010_0_00_00_000_00_0_000_00_0_0_00_0;
      BRANCH:       controls = 26'b00000_0_10_00_000_01_1_111_00_0_0_00_0;
      IMMEXECUTE:   controls = 26'b00000_0_10_10_000_00_0_101_00_0_0_00_0;
      IMMWRITEBACK: controls = 26'b00010_0_00_00_000_00_0_000_00_0_0_00_0;
      LUIEX:        controls = 26'b00010_0_00_00_010_00_0_000_00_0_0_00_0;
      AUIPCEX:      controls = 26'b00010_0_00_00_000_00_0_000_00_0_0_00_0;
      JALEX:        controls = 26'b10010_0_00_00_011_01_0_000_00_0_0_00_0;
      JALREX:       controls = 26'b10010_0_10_10_011_10_0_000_00_0_0_00_0;
      SENDB_GO:     controls = 26'b00000_0_00_00_000_00_0_000_11_0_0_00_0;
      SENDB_WAIT:   controls = 26'b00000_0_00_00_000_00_0_000_00_0_0_00_0;
      RECVB_GO:     controls = 26'b00000_0_00_00_000_00_0_000_01_0_0_00_0;
      RECVB_WAIT:   controls = 26'b00000_0_00_00_000_00_0_000_00_0_0_00_0;
      RECVB_WRITE:  controls = 26'b00010_0_00_00_100_00_0_000_00_0_0_00_0;
      FMEMWB:       controls = 26'b00000_0_00_00_000_00_0_000_00_0_1_00_0;
      FMEMWRITE:    controls = 26'b01000_1_00_00_000_00_0_000_00_1_0_00_0;
      FTEXECUTE:    controls = 26'b00000_0_00_00_000_00_0_000_00_0_0_00_0;
      default:      controls = 26'b00000_x_xx_xx_xxx_xx_x_xxx_xx;  // should never happen
    endcase

endmodule

`default_nettype wire
