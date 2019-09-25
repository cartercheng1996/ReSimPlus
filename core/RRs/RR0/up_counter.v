/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
****************************************************************************************************/
`timescale 1ns/1ps
module up_counter    (
    out     ,
    enable  ,
    clk     ,
    reset
);

    output [7:0] out;
    input enable, clk, reset;
    reg [7:0] out;

always @(posedge clk)
if (reset) begin
  out <= 8'b0 ;
end else if (enable) begin
  out <= out + 1;
end


endmodule
