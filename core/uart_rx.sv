`default_nettype none

module uart_rx #(CLK_PER_HALF_BIT = 5208) (
               output logic [7:0] rdata,
               output logic       rdata_ready,
               output logic       ferr,
               input wire         rxd,
               input wire         clk,
               input wire         rstn);

   localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;

   localparam e_clk_start_bit = CLK_PER_HALF_BIT;

   logic [7:0]                  rxbuf;
   logic [3:0]                  status;
   logic [31:0]                 counter;
   logic                        next;
   logic                        valid;
   logic                        hfin_start_bit;
   logic                        rst_ctr;

   (* ASYNC_REG = "true" *)     reg [2:0] sync_reg;

   assign valid = (&sync_reg) || ~(|sync_reg);     // true iff all the bits are same

   localparam s_idle = 0;
   localparam s_start_bit = 1;
   localparam s_bit_0 = 2;
   localparam s_bit_1 = 3;
   localparam s_bit_2 = 4;
   localparam s_bit_3 = 5;
   localparam s_bit_4 = 6;
   localparam s_bit_5 = 7;
   localparam s_bit_6 = 8;
   localparam s_bit_7 = 9;
   localparam s_stop_bit = 10;

   /* generate event signal */
   always @(posedge clk) begin
      if (~rstn) begin
         counter <= 0;
         next <= 0;
         hfin_start_bit <= 0;
      end else begin
         if (counter == e_clk_bit || rst_ctr) begin
            counter <= 0;
         end else if (status != s_idle) begin
            counter <= counter + 1;
         end
         if (~rst_ctr && counter == e_clk_bit) begin
            next <= 1;
         end else begin
            next <= 0;
         end
         if (~rst_ctr && counter == e_clk_start_bit) begin
            hfin_start_bit <= 1;
         end else begin
            hfin_start_bit <= 0;
         end
      end
   end

   /* syncronize recieved data: eliminate chattering, and metastable */
   always @(posedge clk) begin
     if (~rstn) begin
       sync_reg <= 3'b111;
     end else begin
       sync_reg <= {sync_reg[2:0], rxd};
     end
   end

   /* state machine */
   always @(posedge clk) begin
     if (~rstn) begin
       rdata <= 8'b0;
       rdata_ready <= 0;
       ferr <= 0;
       rxbuf <= 8'b0;
       status <= s_idle;
       rst_ctr <= 0;
     end else begin
       rst_ctr <= 0;
       rdata_ready <= 0;

       if (valid) begin
         if (status == s_idle) begin
           if (~sync_reg[0]) begin
             status <= s_start_bit;
             rst_ctr <= 1;
           end
         end else if (status == s_start_bit) begin
           if (hfin_start_bit) begin
             status <= s_bit_0;
             rst_ctr <= 1;
           end
         end else if (next) begin
           if (status == s_stop_bit) begin
             if (sync_reg[0]) begin
               rdata <= rxbuf;
               rdata_ready <= 1;
               status <= s_idle;
             end else begin
               ferr <= 1;
               status <= s_idle;
             end
           end else begin
               rxbuf <= {sync_reg[0], rxbuf[7:1]};
               status <= status + 1;
           end
         end
       end
     end
   end

endmodule

`default_nettype wire
