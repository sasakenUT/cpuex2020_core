`default_nettype none

module mux2 (input  wire logic [31:0] d0, d1,
             input  wire logic        s,
             output logic      [31:0] y);

  assign y = s ? d1 : d0;

endmodule


module mux3 (input  wire logic [31:0] d0, d1, d2,
             input  wire logic [1:0]  s,
             output logic      [31:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule


module mux4 (input  wire logic [31:0] d0, d1, d2, d3,
             input  wire logic [1:0]  s,
             output logic      [31:0] y);

  always_comb
    case(s)
      2'b00: y = d0;
      2'b01: y = d1;
      2'b10: y = d2;
      2'b11: y = d3;
    endcase

endmodule


/*
module mux5 (input  wire logic [31:0] d0, d1, d2, d3, d4,
             input  wire logic [2:0] s,
             output logic      [31:0] y);

  always_comb
    case(s)
      3'b000: y = d0;
      3'b001: y = d1;
      3'b010: y = d2;
      3'b011: y = d3;
      3'b100: y = d4;
      default: y = d4;
    endcase

endmodule
*/


module mux7 (input  wire logic [31:0] d0, d1, d2, d3, d4, d5, d6,
             input  wire logic [2:0] s,
             output logic      [31:0] y);

  always_comb
    case(s)
      3'b000: y = d0;
      3'b001: y = d1;
      3'b010: y = d2;
      3'b011: y = d3;
      3'b100: y = d4;
      3'b101: y = d5;
      3'b110: y = d6;
      default: y = d0;
    endcase

endmodule


module mux10v (input  wire logic [31:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9,
               input  wire logic [3:0]  s,
               output logic      [31:0] y);

  always_comb
    case(s)
      4'b0000: y = d0;
      4'b0001: y = d1;
      4'b0010: y = d2;
      4'b0011: y = d3;
      4'b0100: y = d4;
      4'b0101: y = d5;
      4'b0110: y = d6;
      4'b0111: y = d7;
      4'b1000: y = d8;
      4'b1001: y = d9;
      default: y = d0;
    endcase

endmodule


module mux10s (input  wire logic        d0, d1, d2, d3, d4, d5, d6, d7, d8, d9,
               input  wire logic [3:0]  s,
               output logic             y);

  always_comb
    case(s)
      4'b0000: y = d0;
      4'b0001: y = d1;
      4'b0010: y = d2;
      4'b0011: y = d3;
      4'b0100: y = d4;
      4'b0101: y = d5;
      4'b0110: y = d6;
      4'b0111: y = d7;
      4'b1000: y = d8;
      4'b1001: y = d9;
      default: y = d0;
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
