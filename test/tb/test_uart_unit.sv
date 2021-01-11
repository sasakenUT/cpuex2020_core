`default_nettype none
`timescale 1 ns / 1 ps

module test_uart_unit();

    // Input, Output signals
    logic       clk, rstn, uart_done, rors, uart_go, txd, rxd;
    logic [7:0] rxdata, txdata;

    // Instanciate The Unit Under Test
    uart_unit uut(clk, rstn, uart_done, rors, uart_go, rxdata, txdata, txd, rxd);

    always begin
        clk <= 1'b1;
        #5;
        clk <= 1'b0;
        #5;
    end

    initial begin
        rstn <= 1'b0;
        #75;
        rstn <= 1'b1;
        rors <= 1'b1;
        uart_go <= 1'b0;
        txdata <= 8'b11110000;
        rxd  <= 1'b0;
        #5;
        uart_go <= 1'b1;
        #5;
        uart_go <= 1'b0;
        rors <= 1'b0;
        #500;
        uart_go <= 1'b1;
        #10;
        uart_go <= 1'b0;
    end

endmodule

`default_nettype wire
