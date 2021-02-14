module itof(
  input wire[31:0]    a,
  input wire          en,
  input wire          clk,
  output reg[31:0]    res,
  output wire         ready
);
  localparam exp_bias_ITOF = 8'd126;

  wire[30:0]  abs_val;
  wire[4:0]   digit;
  wire[7:0]   exp;
  wire[7:0]   exp2;
  wire[22:0]  man;
  wire[6:0]   rem;
  wire[22:0]  ulp;
  wire carry;

  reg reg_ready;

  // assign abs_val = (a[31] == 1'b0) ? a[30:0] : ~a[30:0] + 30'b1;
  // 31-bit increment take long time.
  assign abs_val = (a[31] == 1'b0) ? a[30:0] : ~a[30:0];
  assign exp = {3'b0, digit} + exp_bias_ITOF;
  assign ready = reg_ready;

  cnt_digit ucd(abs_val, digit);
  upper_slice uus(abs_val, man, rem);
  relative_ulp uru(abs_val, ulp, carry);

  always @(posedge clk) begin
    reg_ready <= en;
    res[31] <= a[31];

    if(a[31] == 1'b0) begin
      if(rem[6] & |rem[5:0] == 1'b1) begin
        if(&man == 1'b1) begin
          res[30:0] <= {exp + 8'b1, 23'b0};
        end
        else begin
          res[30:0] <= {exp, man + 23'b1};
        end
      end
      else if(abs_val == 31'b0) begin
        res[30:0] <= 31'b0;
      end
      else begin
        res[30:0] <= {exp, man};
      end
    end
    else begin
      if(digit > 5'd24) begin
        if(rem[6] == 1'b1) begin
          if(&man == 1'b1) begin
            res[30:0] <= {exp + 8'b1, 23'b0};
          end
          else begin
            res[30:0] <= {exp, man + 23'b1};
          end
        end
        else begin
          res[30:0] <= {exp, man};
        end
      end
      else begin
        if(carry == 1'b1) begin
          res[30:0] <= {exp + 8'b1, 23'b0};
        end
        else begin
          res[30:0] <= {exp, man + ulp};
        end
      end
    end
    
    // if(round == 1'b1)begin
    //   if(&man == 1'b1) begin
    //     res <= {a[31], exp + 8'b1, 23'b0};
    //   end
    //   else begin
    //     res <= {a[31], exp, man + 23'b1};
    //   end
    // end
    // else if(abs_val == 31'b0) begin
    //   if(a[31] == 1'b0) begin
    //     res <= 32'b0;
    //   end
    //   else begin
    //     res <= 32'hcf000000;
    //   end
    // end
    // else begin
    //   res <= {a[31], exp, man};
    // end
  end

endmodule