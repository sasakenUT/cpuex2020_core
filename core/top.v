`default_nettype none

module top #(CLK_PER_HALF_BIT = 434) (
           input  wire clk, rstn,
           output wire txd,
           input  wire rxd);

  wire [31:0] adr, writedata, readdata;
  wire        memwrite;
  wire [19:0] addra;

  assign addra = adr[21:2];

  // instantiate processor and memory
  riscv #(CLK_PER_HALF_BIT) riscv(clk, rstn, adr, writedata, memwrite, readdata, txd, rxd);

  blk_mem_gen_0 bram (
    .clka(clk),         // input wire clka
    .wea(memwrite),     // input wire [0 : 0] wea
    .addra(addra),      // input wire [19 : 0] addra
    .dina(writedata),   // input wire [31 : 0] dina
    .douta(readdata)    // output wire [31 : 0] douta
  );

endmodule

`default_nettype wire
