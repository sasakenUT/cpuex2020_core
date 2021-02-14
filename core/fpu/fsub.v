module fadd(
  input   wire[31:0] a,
  input   wire[31:0] b,
  input   wire en,
  input   wire clk,
  output  reg[31:0] c,
  output  wire ready
);

    //stage1
    wire aSign;
    wire[7:0] aExp;
    wire[24:0] aMan;
    wire bSign;
    wire[7:0] bExp;
    wire[24:0] bMan;
    wire[8:0] egap;


    // reg gSign;
    

    //stage2
    wire[26:0] addMan;
    wire[26:0] subMan;
    wire[26:0] normalizedSub;
    wire[4:0] lzc;

    
    // reg sign_and;
    
    

    reg[2:0] reg_ready;
    reg[1:0] sign_xor;
    reg[1:0] reg_sign;
    reg[7:0] gExp;
    reg[24:0] gMan;
    reg[55:0] lMan;

    reg[26:0] midMan;
    reg[7:0] midExp;
    reg[2:0] grs;

    assign aSign = a[31];
    assign aExp = a[30:23];
    assign aMan = aExp != 8'b0 ? {2'b1, a[22:0]} : 25'b0;

    // inverse sign
    assign bSign = ~b[31];
    assign bExp = b[30:23];
    assign bMan = bExp != 8'b0 ? {2'b1, b[22:0]} : 25'b0;

    lzc ulzc(subMan, lzc);
    normalize un(subMan, normalizedSub);

    assign egap = {1'b0, aExp} + {1'b0, ~bExp};
    assign addMan = {gMan, 2'b0} + lMan[55:29];
    assign subMan = {gMan, 2'b0} - lMan[55:29];

    assign ready = reg_ready[2];

  always @(posedge clk) begin

    reg_ready <= {reg_ready[1:0], en};

    //stage 1
    sign_xor <= {sign_xor[0], aSign ^ bSign};

    if(egap[8] == 1'b1) begin
      //ae > be (a > b)
      //gap = (egap+1)[7:0]
      reg_sign <= {reg_sign[0], aSign};
      gExp <= aExp;
      gMan <= aMan;
      lMan <= (egap[7:0] > 8'd30) ? {bMan, 31'b0} >> 31 : {bMan, 31'b0} >> (egap[7:0] + 8'b1);

    end else if(&egap[7:0] == 1'b1) begin
      //ae = be
      if(aMan < bMan) begin
        //a < b
        reg_sign <= {reg_sign[0], bSign};
        gExp <= bExp;
        gMan <= bMan;
        lMan <= {aMan, 31'b0};

      end else begin
        //a >= b
        reg_sign <= {reg_sign[0], aSign};
        gExp <= aExp;
        gMan <= aMan;
        lMan <= {bMan, 31'b0};

      end
    end else begin
      //ae < be (a < b)
      reg_sign <= {reg_sign[0], bSign};
      gExp <= bExp;
      gMan <= bMan;
      lMan <= (~egap[7:0] > 8'd31) ? {aMan, 31'b0} >> 31 : {aMan, 31'b0} >> (~egap[7:0]);   
    end

    //stage 2
    if(sign_xor[0] == 1'b0) begin
      //add
      if(addMan[26] == 1'b1) begin
        // exp++
        midExp <= gExp + {8'b1};
        midMan <= addMan >> 1;
        grs[2:1] <= addMan[2:1];
        grs[0] <= |lMan[29:0];
      end else begin
        midExp <= gExp;
        midMan <= addMan;
        grs[2:1] <= addMan[1:0];
        grs[0] <= |lMan[28:0];
      end
    end else if({1'b0, gExp} > {4'b0, lzc} && lzc != 5'd26) begin
      //sub
      midMan <= normalizedSub;
      midExp <= gExp[7:0] - {2'b0, lzc};
      grs[2:1] <= normalizedSub[1:0];
      grs[0] <= 0;
    end else begin
      //underflow
      midMan <= 0;
      midExp <= 0;
      grs <= 0;
    end

    //stage 3
    if(grs > 3'b100 || (grs == 3'b100 && sign_xor[1] == 1'b0 && midMan[2] == 1'b1)) begin
      if(&midMan[24:2] == 1'b1) begin
        c <= {reg_sign[1], midExp + 8'b1, 23'b0};
      end else begin
        c <= {reg_sign[1], midExp, midMan[24:2] + 23'b1};
      end
    end else begin
      c <= {reg_sign[1], midExp, midMan[24:2]};
    end
 



    // if (stage == 0) begin
    //   //Stage 1
    //   sign_xor <= aSign ^ bSign;
    //   sign_and <= aSign & bSign;

    //   if(egap[8] == 1'b1) begin
    //     //ae > be (a > b)
    //     //gap = (egap+1)[7:0]
    //     gSign <= aSign;
    //     gExp <= aExp;
    //     gMan <= aMan;
    //     lMan <= (egap[7:0] > 8'd30) ? {bMan, 31'b0} >> 31 : {bMan, 31'b0} >> (egap[7:0] + 8'b1);

    //   end else begin
    //     //ae <= be
    //     //gap = (~egap)[7:0]

    //     if(&egap[7:0] == 1'b1) begin
    //       //ae = be
    //       if(aMan < bMan) begin
    //         //a < b
    //         gSign <= bSign;
    //         gExp <= bExp;
    //         gMan <= bMan;
    //         lMan <= {aMan, 31'b0};

    //       end else begin
    //         //a >= b
    //         gSign <= aSign;
    //         gExp <= aExp;
    //         gMan <= aMan;
    //         lMan <= {bMan, 31'b0};

    //       end
    //     end else begin
    //       //ae < be (a < b)
    //       gSign <= bSign;
    //       gExp <= bExp;
    //       gMan <= bMan;
    //       lMan <= (~egap[7:0] > 8'd31) ? {aMan, 31'b0} >> 31 : {aMan, 31'b0} >> (~egap[7:0]);
            
    //     end
    //   end

    //   stage <= 1;
    //   ready <= 0;
    // end else if (stage == 1) begin
    //   //Stage 2

    //   if(sign_xor == 1'b0) begin
    //     //add
    //     if(addMan[26] == 1'b1) begin
    //       // exp++
    //       midExp1 <= gExp + {8'b1};
    //       midMan1 <= addMan >> 1;
    //       grs[2:1] <= addMan[2:1];
    //       grs[0] <= |lMan[29:0];
    //     end else begin
    //       midExp1 <= gExp;
    //       midMan1 <= addMan;
    //       grs[2:1] <= addMan[1:0];
    //       grs[0] <= |lMan[28:0];
    //     end
    //   end else begin
    //     //sub
    //     if({1'b0, gExp} > {4'b0, lzc} && lzc != 5'd26) begin
    //       midMan1 <= normalizedSub;
    //       midExp1 <= gExp[7:0] - {2'b0, lzc};
    //       grs[2:1] <= normalizedSub[1:0];
    //       grs[0] <= 0;
    //     end else begin
    //       //underflow
    //       midMan1 <= 0;
    //       midExp1 <= 0;
    //       grs <= 0;
    //     end
    //   end

    //   stage <= 2;
    // end else if (stage == 2) begin
    //   //Stage 3
    //   if(grs > 3'b100 || (grs == 3'b100 && sign_xor == 1'b0 && midMan1[2] == 1'b1)) begin
    //     if(&midMan1[24:2] == 1'b1) begin
    //       c <= {gSign, midExp1 + 8'b1, 23'b0};
    //     end else begin
    //       c <= {gSign, midExp1, midMan1[24:2] + 23'b1};
    //     end
    //   end else begin
    //     c <= {gSign, midExp1, midMan1[24:2]};
    //   end

    //   stage <= 0;
    //   ready <= 1'b1;
    // end
  end
endmodule

module lzc(
  input   wire[26:0]  man,
  output  wire[4:0]   count
);
  assign count = 
    (man[25] == 1'b1) ? 5'd0 :
    (man[24] == 1'b1) ? 5'd1 :
    (man[23] == 1'b1) ? 5'd2 :
    (man[22] == 1'b1) ? 5'd3 :
    (man[21] == 1'b1) ? 5'd4 :
    (man[20] == 1'b1) ? 5'd5 :
    (man[19] == 1'b1) ? 5'd6 :
    (man[18] == 1'b1) ? 5'd7 :
    (man[17] == 1'b1) ? 5'd8 :
    (man[16] == 1'b1) ? 5'd9 :
    (man[15] == 1'b1) ? 5'd10 :
    (man[14] == 1'b1) ? 5'd11 :
    (man[13] == 1'b1) ? 5'd12 :
    (man[12] == 1'b1) ? 5'd13 :
    (man[11] == 1'b1) ? 5'd14 :
    (man[10] == 1'b1) ? 5'd15 :
    (man[9] == 1'b1) ? 5'd16 :
    (man[8] == 1'b1) ? 5'd17 :
    (man[7] == 1'b1) ? 5'd18 :
    (man[6] == 1'b1) ? 5'd19 :
    (man[5] == 1'b1) ? 5'd20 :
    (man[4] == 1'b1) ? 5'd21 :
    (man[3] == 1'b1) ? 5'd22 :
    (man[2] == 1'b1) ? 5'd23 :
    (man[1] == 1'b1) ? 5'd24 :
    (man[0] == 1'b1) ? 5'd25 : 5'd26;
endmodule

module normalize(
  input   wire[26:0]  man,
  output  wire[26:0]  shifted
);
  assign shifted = 
    (man[25] == 1'b1) ? man:
    (man[24] == 1'b1) ? {man[25:0], 1'b0}:
    (man[23] == 1'b1) ? {man[24:0], 2'b0} :
    (man[22] == 1'b1) ? {man[23:0], 3'b0} :
    (man[21] == 1'b1) ? {man[22:0], 4'b0} :
    (man[20] == 1'b1) ? {man[21:0], 5'b0} :
    (man[19] == 1'b1) ? {man[20:0], 6'b0} :
    (man[18] == 1'b1) ? {man[19:0], 7'b0} :
    (man[17] == 1'b1) ? {man[18:0], 8'b0} :
    (man[16] == 1'b1) ? {man[17:0], 9'b0} :
    (man[15] == 1'b1) ? {man[16:0], 10'b0} :
    (man[14] == 1'b1) ? {man[15:0], 11'b0} :
    (man[13] == 1'b1) ? {man[14:0], 12'b0} :
    (man[12] == 1'b1) ? {man[13:0], 13'b0} :
    (man[11] == 1'b1) ? {man[12:0], 14'b0} :
    (man[10] == 1'b1) ? {man[11:0], 15'b0} :
    (man[9] == 1'b1) ? {man[10:0], 16'b0} :
    (man[8] == 1'b1) ? {man[9:0], 17'b0} :
    (man[7] == 1'b1) ? {man[8:0], 18'b0} :
    (man[6] == 1'b1) ? {man[7:0], 19'b0} :
    (man[5] == 1'b1) ? {man[6:0], 20'b0} :
    (man[4] == 1'b1) ? {man[5:0], 21'b0} :
    (man[3] == 1'b1) ? {man[4:0], 22'b0} :
    (man[2] == 1'b1) ? {man[3:0], 23'b0} :
    (man[1] == 1'b1) ? {man[2:0], 24'b0} :
    (man[0] == 1'b1) ? {man[1:0], 25'b0} : man;
endmodule
