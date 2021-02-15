`default_nettype none

module regfile(input wire logic        clk,
               input wire logic        we3,
               input wire logic [4:0]  ra1, ra2, wa3,
               input wire logic [31:0] wd3,
               output logic     [31:0] rd1, rd2,
               output logic     [31:0] ur3);

  logic [31:0] rf[31:0];

  always_ff @(posedge clk)
    if (we3) rf[wa3] <= wd3;

  assign rd1 = (ra1 != 0) ? rf[ra1] : 32'b0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 32'b0;
  assign ur3 = (wa3 != 0) ? rf[wa3] : 32'b0;

endmodule

`default_nettype wire
