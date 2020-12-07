`default_nettype none

module mux2 (input  wire logic [31:0] d0, d1,
             input  wire logic        s,
             output logic      [31:0] y);

  assign y = s ? d1 : d0;

endmodule

module mux3 (input  wire logic [31:0] d0, d1, d2,
             input  wire logic [1:0]  s,
             output logic      [31:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0);    // need #1 like harris chap7 ans?

endmodule

module mux4 (input  wire logic [31:0] d0, d1, d2, d3,
             input  wire logic [1:0]  s,
             output logic      [31:0] y);

  always_comb
    case(s)
      2'b00: y = d0;    // = or <= ?
      2'b01: y = d1;
      2'b10: y = d2;
      2'b11: y = d3;
    endcase

endmodule

module flopr (input  wire logic        clk, rstn,
              input  wire logic [31:0] d,
              output logic      [31:0] q);

  always_ff @(posedge clk)
    if (~rstn) q <= 32'b0;
    else       q <= d;

endmodule

module flopenr (input  wire logic        clk, rstn,
                input  wire logic        en,
                input  wire logic [31:0] d,
                output logic      [31:0] q);

 always_ff @(posedge clk)
   if      (~rstn) q <= 32'b0;
   else if (en)    q <= d;

endmodule

module setlsb0 (input  wire logic [31:0] a,
                output logic      [31:0] q);

  assign q = {a[31:1], 1'b0};

endmodule

`default_nettype wire
