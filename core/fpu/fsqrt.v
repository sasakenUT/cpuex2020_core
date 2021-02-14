module fsqrt(
  input   wire[31:0]  a,
  input   wire        en,
  input   wire        clk,
  output  reg[31:0]   res,
  output  wire        ready
);
  localparam LATENCY = 3;
  localparam exp_bias = 8'd63;

  wire[9:0] key;
  wire[35:0] value;
  reg[35:0] reg_value;
  reg[LATENCY-2:0] even;
  reg[LATENCY-2:0] sign; 
  reg[7:0] exp[LATENCY-2:0];
  reg[13:0] aManL;
  reg[28:0] ax;
  reg[LATENCY-2:0] od23;
  reg[LATENCY-2:0] zero;

  reg[LATENCY-1:0] reg_ready;

  wire[8:0] exp_plus;

  assign ready = reg_ready[LATENCY-1];
  assign key[9:1] = a[22:14];
  assign key[0] = (a[23] == 0) ? 1'b1: 0;
  assign exp_plus = {1'b0, a[30:23]} + 9'b1;

  fsqrttable ust(key, clk, value);

  always @(posedge clk) begin
    reg_ready <= {reg_ready[LATENCY-2:0], en};
    sign <= {sign[0], a[31]};

    if(a[30:23] == 8'b0) begin
      exp[0] <= 8'b0;
    end else begin
      exp[0] <= exp_bias + exp_plus[8:1];
    end
    exp[1] <= exp[0];

    aManL <= a[13:0];

    even <= {even[0], ~a[23]};
    if(a[23] == 0 && a[22:14] > 10'd63) begin
      od23[0] <= 1'b1;
    end else begin
      od23[0] <= 0;
    end
    od23[1] <= od23[0];

    zero[0] <= (a[30:23] == 8'b0) ? 1'b1 : 1'b0;
    zero[1] <= zero[0];

    //stage 1
    //get reg_value from table
    reg_value <= value;

    //stage 2
    if(even[0] == 0) begin
      ax <= aManL * {2'b01, value[12:0]};
    end else begin
      ax <= aManL * {2'b10, value[12:0]};
    end
    
    //stage 3
    if(zero[1] == 1'b1) begin
      res <= {sign[1], 30'b0};
    end
    else if(od23[1] == 1'b1) begin
      res <= {sign[1], exp[1], {1'b1,reg_value[35:14]} + {9'b0, ax[28:15]}};
    end else begin
      res <= {sign[1], exp[1], {1'b0,reg_value[35:14]} + {9'b0, ax[28:15]}};
    end
  end

endmodule

