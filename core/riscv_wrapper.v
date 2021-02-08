module riscv_wrapper #(CLK_PER_HALF_BIT = 434) (
             input  wire        clk, rstn,
             output wire [31:0] adr, writedata,
             output wire        memwrite,
             input  wire [31:0] readdata,
             output wire        txd,
             input  wire        rxd);

  riscv #(CLK_PER_HALF_BIT) riscv(clk, rstn, adr, writedata, memwrite, readdata, txd, rxd);

endmodule
