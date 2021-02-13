`default_nettype none

module fregfile(input wire logic        clk,
                input wire logic        we3,
                input wire logic [4:0]  ra1, ra2, wa3,
                input wire logic [31:0] wd3,
                output logic     [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  always_ff @(posedge clk)
    if (we3) rf[wa3] <= wd3;

  assign rd1 = rf[ra1];
  assign rd2 = rf[ra2];

endmodule

`default_nettype wire
