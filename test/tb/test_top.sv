`default_nettype none

module test_top(input wire logic clk, rstn);

  logic [31:0] adr, writedata, readdata;
  logic        memwrite;
  logic [19:0] addra;

  assign addra = adr[19:0];

  // instantiate processor and memory
  riscv riscv(clk, rstn, adr, writedata, memwrite, readdata);

  blk_mem_gen_0 bram (
    .clka(clk),         // input wire clka
    .wea(memwrite),     // input wire [0 : 0] wea
    .addra(addra),      // input wire [19 : 0] addra
    .dina(writedata),   // input wire [31 : 0] dina
    .douta(readdata)    // output wire [31 : 0] douta
  );

endmodule

`default_nettype wire
