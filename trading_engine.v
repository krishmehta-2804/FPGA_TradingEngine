module dual_moving_average (
    input clk,
    input rst,
    input [7:0] price_in,
    output reg [7:0] short_ma,
    output reg [7:0] long_ma,
    output reg buy_signal,
    output reg sell_signal,
    output reg [15:0] latency_counter
);

// PARAMETERS
parameter SHORT_W = 4;
parameter LONG_W  = 8;

// REGISTERS
reg [7:0] short_shift [0:SHORT_W-1];
reg [7:0] long_shift  [0:LONG_W-1];

reg [15:0] short_sum;
reg [15:0] long_sum;

reg prev_short_gt_long;

integer i;

// OLD VALUES
wire [7:0] old_short = short_shift[SHORT_W-1];
wire [7:0] old_long  = long_shift[LONG_W-1];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        short_sum <= 0;
        long_sum  <= 0;
        short_ma  <= 0;
        long_ma   <= 0;
        buy_signal  <= 0;
        sell_signal <= 0;
        latency_counter <= 0;
        prev_short_gt_long <= 0;

        for (i = 0; i < SHORT_W; i = i + 1)
            short_shift[i] <= 0;

        for (i = 0; i < LONG_W; i = i + 1)
            long_shift[i] <= 0;
    end
    else begin
        latency_counter <= latency_counter + 1;

        // UPDATE SUMS
        short_sum <= short_sum + price_in - old_short;
        long_sum  <= long_sum  + price_in - old_long;

        // SHIFT REGISTERS
        for (i = SHORT_W-1; i > 0; i = i - 1)
            short_shift[i] <= short_shift[i-1];

        short_shift[0] <= price_in;

        for (i = LONG_W-1; i > 0; i = i - 1)
            long_shift[i] <= long_shift[i-1];

        long_shift[0] <= price_in;

        // COMPUTE MOVING AVERAGES
        short_ma <= short_sum >> 2;  // divide by 4
        long_ma  <= long_sum  >> 3;  // divide by 8

        // CROSS DETECTION
        if (short_ma > long_ma && !prev_short_gt_long)
            buy_signal <= 1;
        else
            buy_signal <= 0;

        if (short_ma < long_ma && prev_short_gt_long)
            sell_signal <= 1;
        else
            sell_signal <= 0;

        prev_short_gt_long <= (short_ma > long_ma);
    end
end

endmodule
