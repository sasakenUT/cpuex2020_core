module ftoi(
  input wire[31:0]  a,
  input wire        mode,
  input wire        en,
  input wire        clk,
  output reg[31:0]  res,
  output wire       ready
);

  localparam MODE_TO_NEAREST = 1'd0;
  localparam MODE_TOWARD_DOWN = 1'd1;
  localparam exp_bias_FTOI = 9'd130;

  wire[8:0] exp;
  wire[4:0] digit;
  wire[30:0] abs_val;
  wire round;
  wire sharp;
  // whether absolute value is less than 1 and more than 0.5.
  wire frac;

  reg reg_ready;

  assign exp = {1'b0, a[30:23]} + exp_bias_FTOI;
  assign digit = (exp[8] == 1'b1) ? exp[4:0] : 5'b0;
  assign frac = (a[30:23] == 8'h7e) ? |a[22:0] : 1'b0;
  assign ready = reg_ready;

  exploit_man uem(a[22:0], digit, abs_val, round, sharp);

  always @(posedge clk) begin

    reg_ready <= en;

    if(a[31] == 1'b0) begin
      if(
        (round == 1'b1 && mode == MODE_TO_NEAREST) ||
        (frac == 1'b1 && mode == MODE_TO_NEAREST)
      ) begin
        res <= {1'b0, abs_val + 31'b1};
      end 
      else begin
        res <= {1'b0, abs_val};
      end
    end
    else begin
      if(mode == MODE_TO_NEAREST && frac == 1'b1) begin
        res <= {32{1'b1}};
      end
      else if(
        (mode == MODE_TO_NEAREST && round == 1'b0) || 
        (mode == MODE_TOWARD_DOWN && sharp == 1'b1)
      ) begin
        // sign bit is 1 unless value is 0. 
        res <= {|abs_val, ~abs_val + 31'b1};
      end
      else begin
        // sign bit is 1 unless value is 0. 
        res <= {~&abs_val, ~abs_val};
      end
    end
  end

endmodule
