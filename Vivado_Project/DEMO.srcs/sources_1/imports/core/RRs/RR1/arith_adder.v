/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
****************************************************************************************************/
`timescale 1ns/1ps
module arith_adder
(
    input clk,
	input       [3:0] data,
	output reg  [3:0] result
);
	always @ (posedge clk)
	begin
			result <= data + 1;
	end

endmodule
