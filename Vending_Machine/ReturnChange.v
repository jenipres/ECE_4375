`timescale 1ns / 1ps
module ReturnChange(amountIn, busy, clk, rst, start, outQ, outD, outN, done);
input clk, rst, start;
output reg outQ, outD, outN, done, busy;
input [9:0] amountIn;

// coin values
parameter Q_VALUE = 25;
parameter D_VALUE = 10;
parameter N_VALUE = 5;

// state encoding
parameter IDLE     = 2'd0;
parameter DISPENSE = 2'd1;
parameter WAIT     = 2'd2;  // gap cycle between coin pulses
parameter DONE     = 2'd3;

reg [1:0] state, next_state;
reg [9:0] remaining, next_remaining;

always @(*) begin 
	 // defaults
        next_state     = state;
        next_remaining = remaining;

        outQ = 0;
        outD = 0;
        outN = 0;
        done = 0; // Default outputs are 0 so coin signals become clean 1-cycle pulses

        busy = (state != IDLE);

        case (state)
         IDLE: begin
                // waiting for start
                if (start) begin
                    next_remaining = amountIn;
                    next_state = DISPENSE;
                end
            end

        DISPENSE: begin
                // if finished, go done
                if (remaining == 0) begin
                    next_state = DONE;
                end
                // greedy: quarter, then dime, then nickel
                else if (remaining >= Q_VALUE) begin
                    outQ = 1;
                    next_remaining = remaining - Q_VALUE;
                    next_state = WAIT;
                end
					 else if (remaining >= D_VALUE) begin
                    outD = 1;
                    next_remaining = remaining - D_VALUE;
                    next_state = WAIT;
                end
					 else if (remaining >= N_VALUE) begin
                    outN = 1;
                    next_remaining = remaining - N_VALUE;
                    next_state = WAIT;
                end
                else begin
                    // not multiple of 5 -> can't dispense exactly with these coins
                    next_state = DONE;
                end
            end

        WAIT: begin
            // gap cycle
            next_state = DISPENSE;
        end

       DONE: begin
                done = 1;          // 1-cycle pulse
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end
	 always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            remaining <= 0;
        end else begin
            state     <= next_state;
            remaining <= next_remaining;
        end
    end
endmodule
