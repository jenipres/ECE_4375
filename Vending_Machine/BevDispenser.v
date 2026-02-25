`timescale 1ns / 1ps
module BevDispenser(
    input  wire        inB1, inB2, inB3, inB4,
    input  wire [9:0]  moneyIn,          // FIX: input, not output
    input  wire        vend_enable,
    output reg         vend_ok,
    output reg  [9:0]  vend_price,
    output reg         outB1, outB2, outB3, outB4,
    input  wire        clk,
    input  wire        rst
);
    parameter B1_COST = 125;
    parameter B2_COST = 220;
    parameter B3_COST = 175;
    parameter B4_COST = 100;

    always @(posedge clk) begin
        if (rst) begin
            outB1 <= 0; outB2 <= 0; outB3 <= 0; outB4 <= 0;
            vend_ok <= 0;
            vend_price <= 0;
        end else begin
            // defaults => clean 1-cycle pulses
            outB1 <= 0; outB2 <= 0; outB3 <= 0; outB4 <= 0;
            vend_ok <= 0;
            vend_price <= 0;

            if (vend_enable) begin
                if (inB1 && moneyIn >= B1_COST) begin
                    outB1 <= 1; vend_ok <= 1; vend_price <= B1_COST;
                end else if (inB2 && moneyIn >= B2_COST) begin
                    outB2 <= 1; vend_ok <= 1; vend_price <= B2_COST;
                end else if (inB3 && moneyIn >= B3_COST) begin
                    outB3 <= 1; vend_ok <= 1; vend_price <= B3_COST;
                end else if (inB4 && moneyIn >= B4_COST) begin
                    outB4 <= 1; vend_ok <= 1; vend_price <= B4_COST;
                end
            end
        end
    end
endmodule
