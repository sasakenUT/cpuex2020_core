/* verilator lint_off DECLFILENAME */

// submodule for itof

module cnt_digit(
  input wire[30:0]  a,
  output wire[4:0]  digit
);

  assign digit = 
    a[30] == 1'b1 ? 5'd31 :
    a[29] == 1'b1 ? 5'd30 :
    a[28] == 1'b1 ? 5'd29 :
    a[27] == 1'b1 ? 5'd28 :
    a[26] == 1'b1 ? 5'd27 :
    a[25] == 1'b1 ? 5'd26 :
    a[24] == 1'b1 ? 5'd25 :
    a[23] == 1'b1 ? 5'd24 :
    a[22] == 1'b1 ? 5'd23 :
    a[21] == 1'b1 ? 5'd22 :
    a[20] == 1'b1 ? 5'd21 :
    a[19] == 1'b1 ? 5'd20 :
    a[18] == 1'b1 ? 5'd19 :
    a[17] == 1'b1 ? 5'd18 :
    a[16] == 1'b1 ? 5'd17 :
    a[15] == 1'b1 ? 5'd16 :
    a[14] == 1'b1 ? 5'd15 :
    a[13] == 1'b1 ? 5'd14 :
    a[12] == 1'b1 ? 5'd13 :
    a[11] == 1'b1 ? 5'd12 :
    a[10] == 1'b1 ? 5'd11 :
    a[9] == 1'b1 ? 5'd10 :
    a[8] == 1'b1 ? 5'd9 :
    a[7] == 1'b1 ? 5'd8 :
    a[6] == 1'b1 ? 5'd7 :
    a[5] == 1'b1 ? 5'd6 :
    a[4] == 1'b1 ? 5'd5 :
    a[3] == 1'b1 ? 5'd4 :
    a[2] == 1'b1 ? 5'd3 :
    a[1] == 1'b1 ? 5'd2 :
    a[0] == 1'b1 ? 5'd1 : 5'd0;

endmodule

module upper_slice(
  input wire[30:0]  a,
  output wire[22:0] slice,
  output wire[6:0]  rem
);

  assign slice =
    a[30] == 1'b1 ? a[29:7] :
    a[29] == 1'b1 ? a[28:6] :
    a[28] == 1'b1 ? a[27:5] :
    a[27] == 1'b1 ? a[26:4] :
    a[26] == 1'b1 ? a[25:3] :
    a[25] == 1'b1 ? a[24:2] :
    a[24] == 1'b1 ? a[23:1] :
    a[23] == 1'b1 ? a[22:0] :
    a[22] == 1'b1 ? {a[21:0], 1'b0} :
    a[21] == 1'b1 ? {a[20:0], 2'b0} :
    a[20] == 1'b1 ? {a[19:0], 3'b0} :
    a[19] == 1'b1 ? {a[18:0], 4'b0} :
    a[18] == 1'b1 ? {a[17:0], 5'b0} :
    a[17] == 1'b1 ? {a[16:0], 6'b0} :
    a[16] == 1'b1 ? {a[15:0], 7'b0} :
    a[15] == 1'b1 ? {a[14:0], 8'b0} :
    a[14] == 1'b1 ? {a[13:0], 9'b0} :
    a[13] == 1'b1 ? {a[12:0], 10'b0} :
    a[12] == 1'b1 ? {a[11:0], 11'b0} :
    a[11] == 1'b1 ? {a[10:0], 12'b0} :
    a[10] == 1'b1 ? {a[9:0], 13'b0} :
    a[9] == 1'b1 ? {a[8:0], 14'b0} :
    a[8] == 1'b1 ? {a[7:0], 15'b0} :
    a[7] == 1'b1 ? {a[6:0], 16'b0} :
    a[6] == 1'b1 ? {a[5:0], 17'b0} :
    a[5] == 1'b1 ? {a[4:0], 18'b0} :
    a[4] == 1'b1 ? {a[3:0], 19'b0} :
    a[3] == 1'b1 ? {a[2:0], 20'b0} :
    a[2] == 1'b1 ? {a[1:0], 21'b0} :
    a[1] == 1'b1 ? {a[0:0], 22'b0} : 23'b0;

  assign rem =
    a[30] == 1'b1 ? a[6:0] :
    a[29] == 1'b1 ? {a[5:0], 1'b0} :
    a[28] == 1'b1 ? {a[4:0], 2'b0}:
    a[27] == 1'b1 ? {a[3:0], 3'b0} :
    a[26] == 1'b1 ? {a[2:0], 4'b0} :
    a[25] == 1'b1 ? {a[1:0], 5'b0} : 
    a[24] == 1'b1 ? {a[0], 6'b0} : 1'b0;

endmodule

module relative_ulp(
  input wire[30:0] a,
  output wire[22:0] ulp,
  output wire carry
);

  assign ulp = 
    |a[30:24] == 1'b1 ? 23'b0 :
    a[23] == 1'b1 ? 23'h1 :
    a[22] == 1'b1 ? 23'h2 :
    a[21] == 1'b1 ? 23'h4 :
    a[20] == 1'b1 ? 23'h8 :
    a[19] == 1'b1 ? 23'h10 :
    a[18] == 1'b1 ? 23'h20 :
    a[17] == 1'b1 ? 23'h40 :
    a[16] == 1'b1 ? 23'h80 :
    a[15] == 1'b1 ? 23'h100 :
    a[14] == 1'b1 ? 23'h200 :
    a[13] == 1'b1 ? 23'h400 :
    a[12] == 1'b1 ? 23'h800 :
    a[11] == 1'b1 ? 23'h1000 :
    a[10] == 1'b1 ? 23'h2000 :
    a[9] == 1'b1 ? 23'h4000 :
    a[8] == 1'b1 ? 23'h8000 :
    a[7] == 1'b1 ? 23'h10000 :
    a[6] == 1'b1 ? 23'h20000 :
    a[5] == 1'b1 ? 23'h40000 :
    a[4] == 1'b1 ? 23'h80000 :
    a[3] == 1'b1 ? 23'h100000 :
    a[2] == 1'b1 ? 23'h200000 :
    a[1] == 1'b1 ? 23'h400000 : 23'h800000;

  assign carry = 
    |a[30:24] == 1'b1 ? 1'b0 :
    a[23] == 1'b1 ? &a[22:0] :
    a[22] == 1'b1 ? &a[21:0] :
    a[21] == 1'b1 ? &a[20:0] :
    a[20] == 1'b1 ? &a[19:0] :
    a[19] == 1'b1 ? &a[18:0] :
    a[18] == 1'b1 ? &a[17:0] :
    a[17] == 1'b1 ? &a[16:0] :
    a[16] == 1'b1 ? &a[15:0] :
    a[15] == 1'b1 ? &a[14:0] :
    a[14] == 1'b1 ? &a[13:0] :
    a[13] == 1'b1 ? &a[12:0] :
    a[12] == 1'b1 ? &a[11:0] :
    a[11] == 1'b1 ? &a[10:0] :
    a[10] == 1'b1 ? &a[9:0] :
    a[9] == 1'b1 ? &a[8:0] :
    a[8] == 1'b1 ? &a[7:0] :
    a[7] == 1'b1 ? &a[6:0] :
    a[6] == 1'b1 ? &a[5:0] :
    a[5] == 1'b1 ? &a[4:0] :
    a[4] == 1'b1 ? &a[3:0] :
    a[3] == 1'b1 ? &a[2:0] :
    a[2] == 1'b1 ? &a[1:0] :
    a[1] == 1'b1 ? a[0] : 1'b1;

endmodule

// submodule for ftoi

module exploit_man(
  input wire[22:0]  man,
  input wire[4:0]   digit,
  output wire[30:0] res,
  output wire       round,
  output wire       sharp
);

  assign res = 
    digit == 5'd31 ? {1'b1, man, 7'b0} :
    digit == 5'd30 ? {2'b1, man, 6'b0} :
    digit == 5'd29 ? {3'b1, man, 5'b0} :
    digit == 5'd28 ? {4'b1, man, 4'b0} :
    digit == 5'd27 ? {5'b1, man, 3'b0} :
    digit == 5'd26 ? {6'b1, man, 2'b0} :
    digit == 5'd25 ? {7'b1, man, 1'b0} :
    digit == 5'd24 ? {8'b1, man} :
    digit == 5'd23 ? {9'b1, man[22:1]} :
    digit == 5'd22 ? {10'b1, man[22:2]} :
    digit == 5'd21 ? {11'b1, man[22:3]} :
    digit == 5'd20 ? {12'b1, man[22:4]} :
    digit == 5'd19 ? {13'b1, man[22:5]} :
    digit == 5'd18 ? {14'b1, man[22:6]} :
    digit == 5'd17 ? {15'b1, man[22:7]} :
    digit == 5'd16 ? {16'b1, man[22:8]} :
    digit == 5'd15 ? {17'b1, man[22:9]} :
    digit == 5'd14 ? {18'b1, man[22:10]} :
    digit == 5'd13 ? {19'b1, man[22:11]} :
    digit == 5'd12 ? {20'b1, man[22:12]} :
    digit == 5'd11 ? {21'b1, man[22:13]} :
    digit == 5'd10 ? {22'b1, man[22:14]} :
    digit == 5'd9 ? {23'b1, man[22:15]} :
    digit == 5'd8 ? {24'b1, man[22:16]} :
    digit == 5'd7 ? {25'b1, man[22:17]} :
    digit == 5'd6 ? {26'b1, man[22:18]} :
    digit == 5'd5 ? {27'b1, man[22:19]} :
    digit == 5'd4 ? {28'b1, man[22:20]} :
    digit == 5'd3 ? {29'b1, man[22:21]} :
    digit == 5'd2 ? {30'b1, man[22:22]} :
    digit == 5'd1 ? 31'b1 : 31'b0;

  assign round =
    digit == 5'd22 ? man[1] & man[0] :
    digit == 5'd21 ? man[2] & |man[1:0] :
    digit == 5'd20 ? man[3] & |man[2:0] :
    digit == 5'd19 ? man[4] & |man[3:0] :
    digit == 5'd18 ? man[5] & |man[4:0] :
    digit == 5'd17 ? man[6] & |man[5:0] :
    digit == 5'd16 ? man[7] & |man[6:0] :
    digit == 5'd15 ? man[8] & |man[7:0] :
    digit == 5'd14 ? man[9] & |man[8:0] :
    digit == 5'd13 ? man[10] & |man[9:0] :
    digit == 5'd12 ? man[11] & |man[10:0] :
    digit == 5'd11 ? man[12] & |man[11:0] :
    digit == 5'd10 ? man[13] & |man[12:0] :
    digit == 5'd9 ? man[14] & |man[13:0] :
    digit == 5'd8 ? man[15] & |man[14:0] :
    digit == 5'd7 ? man[16] & |man[15:0] :
    digit == 5'd6 ? man[17] & |man[16:0] :
    digit == 5'd5 ? man[18] & |man[17:0] :
    digit == 5'd4 ? man[19] & |man[18:0] :
    digit == 5'd3 ? man[20] & |man[19:0] :
    digit == 5'd2 ? man[21] & |man[20:0] :
    digit == 5'd1 ? man[22] & |man[21:0] : 1'b0;

  assign sharp =
    digit == 5'd23 ? ~man[0] :
    digit == 5'd22 ? ~|man[1:0] :
    digit == 5'd21 ? ~|man[2:0] :
    digit == 5'd20 ? ~|man[3:0] :
    digit == 5'd19 ? ~|man[4:0] :
    digit == 5'd18 ? ~|man[5:0] :
    digit == 5'd17 ? ~|man[6:0] :
    digit == 5'd16 ? ~|man[7:0] :
    digit == 5'd15 ? ~|man[8:0] :
    digit == 5'd14 ? ~|man[9:0] :
    digit == 5'd13 ? ~|man[10:0] :
    digit == 5'd12 ? ~|man[11:0] :
    digit == 5'd11 ? ~|man[12:0] :
    digit == 5'd10 ? ~|man[13:0] :
    digit == 5'd9 ? ~|man[14:0] :
    digit == 5'd8 ? ~|man[15:0] :
    digit == 5'd7 ? ~|man[16:0] :
    digit == 5'd6 ? ~|man[17:0] :
    digit == 5'd5 ? ~|man[18:0] :
    digit == 5'd4 ? ~|man[19:0] :
    digit == 5'd3 ? ~|man[20:0] :
    digit == 5'd2 ? ~|man[21:0] :
    digit == 5'd1 ? ~|man[22:0] : 
    digit == 5'd0 ? 1'b0 : 1'b1;

endmodule

/* verilator lint_on DECLFILENAME */