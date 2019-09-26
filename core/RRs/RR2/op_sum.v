/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
****************************************************************************************************/
module op_sum
(
	input clk,
	input [3:0] dataa,
	input [3:0] datab,
	output reg [4:0] result
);

	always @ (posedge clk)
	begin
			result <= dataa + datab;
	end

endmodule
