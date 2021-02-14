module finvtable (
  input   wire[9:0]   key,
  input   wire        clk,
  output  wire[35:0]   value
);

assign value = out;

reg[35:0] out;
(* ram_style = "block" *) reg[35:0] ram[1023:0];
 initial begin
   $readmemh("invTable.mem",ram,0,1023);
 end

always @(posedge clk) begin
  out <= ram[key];
end

endmodule