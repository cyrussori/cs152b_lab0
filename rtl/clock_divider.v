`timescale 1ns / 1ps 

// -------------------------------------------------------------------------------------------------
// Clock divider
// 
// Module overview:
//  - Basys3's clk = 100MHz; So, 100 million cycles will have elapsed every second.
//  - On the 100 millionth cycle, tick goes high and allows the counter to increment.
//  - Reset is asynchronous.
//
// -------------------------------------------------------------------------------------------------


module clock_divider 
#(
  parameter integer DIVISOR = 100_000_000
)(
  input  wire clk,
  input  wire rst,
  output wire tick
);
  
  localparam integer DATA_W = (DIVISOR > 1) ? $clog2(DIVISOR) : 1;
  localparam integer LAST_COUNT = DIVISOR - 1;
  reg [DATA_W-1:0] ncycles;

  assign tick = !rst && (ncycles == LAST_COUNT[DATA_W-1:0]);

  always @(posedge clk or posedge rst) begin 
    if (rst) ncycles <= {DATA_W{1'b0}};
    else if (tick) ncycles <= {DATA_W{1'b0}};
    else ncycles <= ncycles + 1'b1;
  end

endmodule
