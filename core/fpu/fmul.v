module fmul(
    input   wire[31:0] a,
    input   wire[31:0] b,
    input   wire en,
    input   wire clk,
    output  reg [31:0] c,
    output  wire ready
);
    localparam signed [9:0] exp_bias = 10'd129;

    wire aSign;
    wire[7:0] aExp;
    wire[11:0] aHi;
    wire[10:0] aLo;

    wire bSign;
    wire[7:0] bExp;
    wire[11:0] bHi;
    wire[10:0] bLo;

    wire roundup1;
    wire roundup2;

    reg[25:0] HH;
    reg[23:0] HL;
    reg[23:0] LH;
    reg[3:0] LL;
    reg[27:0] man;
    reg[8:0] exp;
    reg[8:0] exp_plus;
    reg sign;

    reg[2:0] reg_ready;
    reg[1:0] reg_zero;
    reg[9:0] reg_exp[1:0];
    reg[1:0] reg_sign;

    reg round;

    assign aSign = a[31];
    assign aExp = a[30:23];
    assign aHi = a[22:11];
    assign aLo = a[10:0];

    assign bSign = b[31];
    assign bExp = b[30:23];
    assign bHi = b[22:11];
    assign bLo = b[10:0];

    assign roundup1 = &man[26:4];
    assign roundup2 = &man[25:3];

    assign ready = reg_ready[2];

    always @(posedge clk) begin

        reg_ready <= {reg_ready[1:0], en};

        //stage 1
        HH <= {1'b1, aHi} * {1'b1, bHi};
        HL <= {1'b1, aHi} * {2'b0, bLo};
        LH <= {2'b0, aLo} * {1'b1, bHi};
        LL <= aLo[10:9] * bLo[10:9];
        reg_zero[0] <= (aExp == 8'b0 && bExp == 8'b0) ? 1'b1 : 1'b0;
        reg_zero[1] <= reg_zero[0];
        reg_exp[0] <= {2'b0, aExp} + {2'b0, bExp} + exp_bias;
        reg_exp[1] <= reg_exp[0];
        reg_sign <= {reg_sign[0], aSign ^ bSign};

        //stage 2
        man <= {HH, 2'b0} + {13'b0, HL[23:9]} + {13'b0, LH[23:9]} + {26'b0, LL[3:2]};

        //stage 3
        if(reg_zero[1] == 1'b1 || reg_exp[1][9:8] == 2'b0) begin
            //zero or underflow
            c <= {reg_sign[1], 31'b0};
        end else if (reg_exp[1][9] >= 1'b1) begin
            //overflow
            c <= {reg_sign[1], {8{1'b1}}, 23'b0};
        end else if (man[27] == 1'b1 && reg_exp[1][7:0] != 8'd255) begin
            if(man[3:0] >= 4'b1000) begin
                c <= {reg_sign[1], reg_exp[1][7:0] + 8'b1 + {7'b0, roundup1}, man[26:4] + 23'b1};
            end else begin
                c <= {reg_sign[1], reg_exp[1][7:0] + 8'b1, man[26:4]};
            end
        end else begin
            if(man[2:0] >= 3'b100) begin
                c <= {reg_sign[1], reg_exp[1][7:0] + { 7'b0, roundup2 }, man[25:3] + 23'b1};
            end else begin
                c <= {reg_sign[1], reg_exp[1][7:0], man[25:3]};
            end
        end


        // if (stage == 0) begin
        //     //Stage 1
        //     //仮数部を�?割してそれぞれ計�?
        //     HH <= {1'b1, aHi} * {1'b1, bHi};
        //     HL <= {1'b1, aHi} * {2'b0, bLo};
        //     LH <= aLo * bHi;

        //     //�?数部を計�?
        //     exp <= {1'b0, aExp} + {1'b0, bExp} + exp_bias;

        //     //符号部を計�?
        //     sign <= aSign ^ bSign;

        //     ready <= 1'b0;
        //     stage <= 1;
        // end else if (stage == 1) begin
        //     //Stage 2
        //     //仮数部を算�?�
        //     man <= HH + {14'b0, HL[23:13]} + {14'b0, LH[23:13]};

        //     //�?数部に1足したも�?�
        //     exp_plus <= exp + 8'b1;

        //     stage <= 2;
        // end else if (stage == 2) begin
        //     //Stage 3
        //     //仮数部を正規化して答えを返す
        //     c <= man[25] ? 
        //         {sign, exp_plus[7:0], man[24:2]} :
        //         {sign, exp[7:0], man[23:1]};
        //
        //     ready <= 1'b1;
        //     stage <= 0;
        // end
    end
endmodule
