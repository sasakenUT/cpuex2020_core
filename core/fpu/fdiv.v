module fdiv(
    input wire[31:0]    a,
    input wire[31:0]    b,
    input wire          en,
    input wire          clk,
    output wire[31:0]    c,
    output wire         ready
);

    localparam exp_sum = 9'd254 + 9'd129;
    localparam LATENCY = 4;

    reg[LATENCY-1:0]    reg_ready;
    reg[LATENCY-1:0]    sign;
    reg[8:0]            exp[LATENCY-1:0]; 
    reg[LATENCY-1:0]    zero;
    reg[LATENCY-1:0]    underflow;
    // reg[36:0]           reg_value;

    reg[12:0]           reg_aManH[2:0];
    reg[10:0]           reg_aManL[2:0];
    reg[12:0]           reg_bManL;

    reg[26:0]          bx;

    reg[25:0]           acHH[1:0];
    reg[23:0]           acHL[1:0];
    reg[23:0]           acLH[1:0];
    reg[21:0]           acLL[1:0];
    reg[26:0]           agH;
    reg[24:0]           agL;

    reg[22:0]           reg_man;

    wire                aSign;
    wire[7:0]           aExp;
    // wire[22:0]          aMan;
    wire                bSign;
    wire[7:0]           bExp;
    wire[22:0]          bMan;

    wire[9:0]           key;
    wire[35:0]          value;

    wire[27:0]          man;

    

    assign aSign = a[31];
    assign aExp = a[30:23];
    assign bSign = b[31];
    assign bExp = b[30:23];
    assign bMan = b[22:0];
    assign key = b[22:13];

    assign man = {acHH[1], 2'b0} + {13'b0, acHL[1][23:9]} + {13'b0, acLH[1][23:9]} + {26'b0, acLL[1][21:20]} - {9'b0, agH[26:8]} - {23'b0, agL[24:20]};
    assign c = {sign[LATENCY-1], exp[LATENCY-1][7:0], reg_man};
    assign ready = reg_ready[LATENCY-1];

    finvtable uit(key, clk, value);

    always @(posedge clk) begin
        reg_ready <= {reg_ready[LATENCY-2:0], en};

        sign <= {sign[LATENCY-2:0], aSign ^ bSign};

        if(aExp == 8'b0) begin
            exp[0] <= 9'b0;
            underflow[0] <= 0'b0;
        end else if (bMan == 23'b0) begin
            if ({1'b0, aExp} + 9'd127 < {1'b0, bExp}) begin
                exp[0] <= 9'b0;
                underflow[0] <= 1'b1;
            end else begin
                exp[0] <= {1'b0 ,aExp} + exp_sum - {1'b0, bExp};
                underflow[0] <= 1'b0;
            end
            zero[0] <= 1'b1;
        end else if({1'b0, aExp} + 9'd126 < {1'b0, bExp})begin
            exp[0] <= 9'b0;
            underflow[0] <= 1'b1;
            zero[0] <= 1'b0;
        end else begin
            exp[0] <= {1'b0 ,aExp} + exp_sum - {1'b0, bExp} - 9'b1;
            underflow[0] <= 1'b0;
            zero[0] <= 1'b0;
        end
        
        exp[1] <= exp[0];
        exp[2] <= exp[1];
        exp[3] <= exp[2];
        zero[LATENCY-1:1] <= zero[LATENCY-2:0];
        underflow[LATENCY-1:1] <= underflow[LATENCY-2:0];

        reg_aManH[0] <= {1'b1, a[22:11]};
        reg_aManH[1] <= reg_aManH[0];
        reg_aManH[2] <= reg_aManH[1];
        reg_aManL[0] <= a[10:0];
        reg_aManL[1] <= reg_aManL[0];
        reg_aManL[2] <= reg_aManL[1];
        reg_bManL <= b[12:0];

        //stage1 
        //get value from invTable
        // reg_value <= {1'b1, value};

        //stage2
        bx <= reg_bManL * value[12:0];
        acHH[0] <= reg_aManH[0] * {1'b1, value[35:24]};
        acHL[0] <= reg_aManH[0] * value[23:13];
        acLH[0] <= reg_aManL[0] * {1'b1, value[35:24]};
        acLL[0] <= reg_aManL[0] * value[23:13];
        acHH[1] <= acHH[0];
        acHL[1] <= acHL[0];
        acLH[1] <= acLH[0];
        acLL[1] <= acLL[0];

        //stage3
        agH <= reg_aManH[1] * bx[26:13];
        agL <= reg_aManL[1] * bx[26:13];

        //stage4
        if(zero[2] == 1'b1) begin
            reg_man <= {reg_aManH[2][11:0], reg_aManL[2]};
        end else begin
            if(underflow[2] == 1'b0 && man[27] == 1'b1) begin
                reg_man <= man[26:4];
                exp[3] <= exp[2] + 9'b1;
            end else begin
                reg_man <= man[25:3];
            end
        end
    end
endmodule
