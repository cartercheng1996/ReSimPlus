`timescale 1ns/1ps
module count_rm0(
   input        rst,
   input        clk,
   output [3:0] count_out);

      count_up inst_count (
      .rst       (rst),
      .clk       (clk),
      .count_out (count_out)
   );
endmodule
