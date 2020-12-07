`default_nettype none

module dmem(input  wire logic        clk, we,
            input  wire logic [31:0] adr, wd,
            output logic      [31:0] rd);

  logic [31:0] RAM[63:0];

  assign rd = RAM[adr[31:2]];   // word aligned

  always_ff @(posedge clk)
    if (we) RAM[adr[31:2]] <= wd;

endmodule

`default_nettype wire
