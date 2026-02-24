



`timescale 1ns/1ps

module tb;

reg clk = 0;
reg rst = 1;
reg [7:0] price_in;

wire [7:0] short_ma;
wire [7:0] long_ma;
wire buy_signal;
wire sell_signal;
wire [15:0] latency_counter;

dual_moving_average uut (
    .clk(clk),
    .rst(rst),
    .price_in(price_in),
    .short_ma(short_ma),
    .long_ma(long_ma),
    .buy_signal(buy_signal),
    .sell_signal(sell_signal),
    .latency_counter(latency_counter)
);

// CLOCK
always #5 clk = ~clk;

// WAVEFORM
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
end

initial begin
    #10 rst = 0;

    // Rising market
    price_in = 10; #10;
    price_in = 20; #10;
    price_in = 30; #10;
    price_in = 40; #10;
    price_in = 60; #10;
    price_in = 80; #10;
    price_in = 100; #10;

    // Falling market
    price_in = 70; #10;
    price_in = 50; #10;
    price_in = 30; #10;
    price_in = 10; #10;

    #100 $finish;
end

endmodule

