`default_nettype none

module test_top(input  wire logic        clk, rstn,
                output logic      [31:0] writedata, adr,
                output logic             memwrite);

  logic [31:0] readdata;

  // instantiate processor and memory
  riscv riscv(clk, rstn, adr, writedata, memwrite, readdata);
  dmem  mem(clk, memwrite, adr, writedata, readdata);

endmodule

`default_nettype wire
