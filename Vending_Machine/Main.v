`timescale 1ns / 1ps
module Main(
    input  wire clk,
    input  wire rst,
    input  wire cancel,
    input  wire inB1, inB2, inB3, inB4,
    input  wire inQ, inD, inN,
    output wire outQ, outD, outN,
    output wire outB1, outB2, outB3, outB4
);

    // Internal signals
    wire [9:0] credit;
    wire       vend_ok;
    wire [9:0] vend_price;

    reg        resetCount;
    reg        vend_pulse;

    reg        rc_start;
    reg  [9:0] rc_amount;
    wire       rc_done;
    wire       rc_busy;

    wire any_select = inB1 | inB2 | inB3 | inB4;

    // --- Coin counter (credit) ---
    CoinCounter CC (
        .clk(clk),
        .rst(rst),
        .inQ(inQ),              // FIX: was inquarter
        .inD(inD),              // FIX: was indime
        .inN(inN),              // FIX: was innickel
        .resetCount(resetCount),
        .outCount(credit)
    );

    // --- Beverage dispenser ---
    BevDispenser BD (
        .clk(clk),
        .rst(rst),
        .inB1(inB1),            // FIX: was sel1
        .inB2(inB2),            // FIX: was sel2
        .inB3(inB3),            // FIX: was sel3
        .inB4(inB4),            // FIX: was sel4
        .moneyIn(credit),
        .vend_enable(vend_pulse),
        .outB1(outB1),
        .outB2(outB2),
        .outB3(outB3),
        .outB4(outB4),
        .vend_ok(vend_ok),
        .vend_price(vend_price)
    );

    // --- Change return module ---
    ReturnChange RC (
        .clk(clk),
        .rst(rst),
        .start(rc_start),
        .amountIn(rc_amount),
        .outQ(outQ),
        .outD(outD),
        .outN(outN),
        .done(rc_done),
        .busy(rc_busy)
    );

    //========================
    // Controller FSM
    //========================
    localparam S_IDLE        = 3'd0;
    localparam S_VEND_PULSE  = 3'd1;
    localparam S_VEND_DECIDE = 3'd2;
    localparam S_START_CHG   = 3'd3;
    localparam S_WAIT_CHG    = 3'd4;
    localparam S_RESET       = 3'd5;

    reg [2:0] state, next_state;
    reg [9:0] next_rc_amount;

    always @(*) begin
        // defaults
        next_state = state;

        resetCount = 1'b0;
        vend_pulse = 1'b0;
        rc_start   = 1'b0;
        next_rc_amount = rc_amount;

        case (state)
            S_IDLE: begin
                // Cancel => return all credit (if any)
                if (cancel && credit != 0) begin
                    next_rc_amount = credit;
                    next_state = S_START_CHG;
                end
                // Any selection attempt => pulse vend_enable
                else if (any_select) begin
                    next_state = S_VEND_PULSE;
                end
            end

            S_VEND_PULSE: begin
                vend_pulse = 1'b1;      // 1-cycle pulse
                next_state = S_VEND_DECIDE;
            end

            S_VEND_DECIDE: begin
                if (vend_ok) begin
                    // Transaction ends after one beverage.
                    // If overpaid, return change.
                    if (credit > vend_price) begin
                        next_rc_amount = credit - vend_price;
                        next_state = S_START_CHG;
                    end else begin
                        next_state = S_RESET;
                    end
                end else begin
                    // Not enough money or no valid selection
                    next_state = S_IDLE;
                end
            end

            S_START_CHG: begin
                rc_start = 1'b1;        // 1-cycle start pulse
                next_state = S_WAIT_CHG;
            end

            S_WAIT_CHG: begin
                if (rc_done) begin
                    next_state = S_RESET;
                end
            end

            S_RESET: begin
                resetCount = 1'b1;      // clear credit
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            rc_amount <= 10'd0;
        end else begin
            state <= next_state;
            rc_amount <= next_rc_amount;
        end
    end

endmodule
