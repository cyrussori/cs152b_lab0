`timescale 1ns / 1ps

module tb_counter_4bit;

  reg        clk;
  reg        rst;
  wire [3:0] count;
  
  parameter integer CLK_HZ = 2;
  integer edges;

  counter_4bit #(
    .CLK_HZ (CLK_HZ)
  ) dut (
    .clk   (clk),
    .rst   (rst),
    .count (count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task fail;
    begin
      $display("FAIL at %0t", $time);
      $stop;
      $finish;
    end
  endtask

  // Reference Model
  function [3:0] expected_value;
    input integer num_edge;
    begin 
      expected_value = num_edge / CLK_HZ;
    end
  endfunction

  task check_count;
    input [3:0] expected;
    begin 
      if (expected !== count) 
        $fatal(1, "FAIL at %0t: edges=%0d expected=%0d actual=%0d", $time, edges, expected, count);
    end
  endtask

  task check_ref;
    begin 
      check_count(expected_value(edges));
    end
  endtask

  task increment;
    input integer num_cycles;
    integer i;
    begin 
      for (i = 0; i < num_cycles; i = i + 1) begin
        @(posedge clk);
        #2;
        check_ref();
      end
    end
  endtask

  always @(posedge clk or posedge rst) begin 
    if (rst) edges <= 0;
    else edges <= edges + 1;
  end

  task init;
    begin 
      rst = 1'b1;
      @(posedge clk);
      #2;
      check_count(4'd0);
      check_ref();
      @(negedge clk);
      rst = 1'b0;
    end
  endtask

  initial begin 
    $dumpfile("build/counter_4bit.vcd");
    $dumpvars(0, tb_counter_4bit);
    init();
    #1;

    increment(CLK_HZ - 1);
    check_count(4'd0);

    increment(1);
    check_count(4'd1);

    increment(1);
    check_count(4'd1);

    increment(CLK_HZ - 1);
    check_count(4'd2);

    init();

    increment(CLK_HZ * 15);
    check_count(4'd15);

    increment(CLK_HZ - 1);
    check_count(4'd15);

    increment(1);
    check_count(4'd0);

    increment(CLK_HZ - 1);

    $display("PASS: reset, interval boundaries, and 4-bit rollover");
    $finish;
  end
endmodule
