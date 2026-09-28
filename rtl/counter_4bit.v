`timescale 1ns / 1ps

// -------------------------------------------------------------------------------------------------
// 4-bit Counter
// 
// Module overview:
//  - Increments every second.
//  - Overflows to 0 once it reaches 15.
//  - Reset is asynchronous.
//
// -------------------------------------------------------------------------------------------------

module counter_4bit
(
  input  wire       clk,
  input  wire       rst,
  output wire [3:0] count
);

  wire tick; // Tap the output of the divisor
  reg [3:0] c_count; // So count can be updated in the procedural block.

  clock_divider clk_div (
    .clk  (clk),
    .rst  (rst)
    .tick (tick)
  );

  assign count = c_count;

  always @(posedge clk or posedge rst) begin 
    if (rst) c_count <= 4'b0;
    else if (tick) c_count <= c_count + 4'b1;
  end

endmodule
