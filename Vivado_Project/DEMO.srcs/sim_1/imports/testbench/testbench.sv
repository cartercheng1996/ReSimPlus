/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia
This is the testbench provided by designer
****************************************************************************************************/

`timescale 1ns/1ps
module testbench ();
	reg  		rstn;
	reg  [31:0] light_intensity;
	reg   [3:0] count_out;
	reg         xbs_select;
    reg  [31:0] mem_addr;
    reg  [31:0] mem_data_in;
    reg         mem_rnw;
    reg  [ 3:0] mem_be;
    reg         mem_ack;
    reg  [31:0] mem_data_out;




//-------------------------------------------------------------------
// Reconfiguration-trriger
//-------------------------------------------------------------------
	initial
		begin
			rstn = 0; light_intensity =   0; #100;
			rstn = 1; light_intensity =  80; #100000;
			rstn = 1; light_intensity = 180; #100000;
			rstn = 0; light_intensity =   0; #100000;
			rstn = 1; light_intensity = 180; #100000;
			rstn = 1; light_intensity = 270; #100000;
			rstn = 1; light_intensity = 370; #100000;
			rstn = 0; light_intensity = 220; #100000;
			rstn = 1; light_intensity = 370; #100000;
			rstn = 1; light_intensity =  70; #100000;
	end

//-------------------------------------------------------------------
// simulation-only clock period=10ns 100 MHz
//-------------------------------------------------------------------
	reg clock;
	initial clock=0;
	always #5 clock=~clock;

//-------------------------------------------------------------------
// DRS-design Top
//-------------------------------------------------------------------
	top top_0(clock,rstn,light_intensity,count_out,xbs_select,
				mem_addr,mem_data_in,mem_rnw,mem_be,mem_ack,
				mem_data_out);

//-------------------------------------------------------------------
// Virtual external re-configuration memory
//-------------------------------------------------------------------

	memctrl mem_0(
		.clk              (clock              ), // external clock
		.rstn             (                   ), // not use pin

		.xbs_select       (xbs_select         ), // mem select signal, sel=1 mem enable
		.xbs_addr         (mem_addr           ), // mem address selection
		.xbs_data         (mem_data_in        ), // mem 32-bit data input AXI
		.xbs_rnw          (mem_rnw            ), // rnw=1, read mode; rnw=0, write mode
		.xbs_be           (mem_be             ), // byte selction, (1000 = select first byte, 1111 = select all)
		.sl_ack           (mem_ack            ), // data ready ack, normal delay is 3 cycle
		.sl_data          (mem_data_out       )  // 32 bit mem output data
	);



endmodule
