module fsqrttable (
  input   wire[9:0]   key,
  input   wire        clk,
  output  wire[35:0]   value
);

assign value = out;

reg[35:0] out;
reg[35:0] ram[1023:0];
 initial begin
   $readmemh("sqrtTable.mem",ram,0,1023);
 end

always @(posedge clk) begin
  out <= ram[key];
end

endmodule