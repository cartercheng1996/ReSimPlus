/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
****************************************************************************************************/
module op_comparer
(
	input clk,
	input 		[3:0] dataa,
	input 		[3:0] datab,
	output reg 	[4:0] result
);

	reg [3:0] compare;

	always @ (posedge clk)
	begin
		compare = dataa - datab;
	end

	always @ (*)
	begin
		if (compare > 4'b0000) begin
			result <= 5'b00001;
		end else if (compare == 4'b0000) begin
			result <= 5'b00000;
		end else begin
			result <= 5'b11111;

		end
	end
endmodule
