/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia

This is ReSimPlus auto generated file, use for simulation only!

The purpose of this file is to instantiate all RMs included in the RR region and connect each of them
by the virtual MUXs. Therefore, it allows ReSimPlus can select one of the RM in each RR to be
actived depended on the ICAPI bitstream traffic (When the condiction of re-configuration is
triggered, bitstream contain selected RM ID infomation will be updated through this ICAPI port).
****************************************************************************************************/

`timescale 1ns/1ps

//---------------------------------------------
//           Instantiating I/O port
//---------------------------------------------
module arith 
(
   input   clk,
   input   [3:0] data,
   output reg [3:0] result
);

//---------------------------------------------
//   Instantiating reconfigurable MUX-Logic
//---------------------------------------------

    //RM0 Interface
    reg       RM0_active;
    reg       RM0_clk;
    reg [3:0] RM0_data;
    wire [3:0] RM0_result;

    //RM1 Interface
    reg       RM1_active;
    reg       RM1_clk;
    reg [3:0] RM1_data;
    wire [3:0] RM1_result;


//---------------------------------------------
// Instantiating MUX connecting all RMs in RR
//---------------------------------------------

    always@(*) begin
        if (RM0_active) begin
            RM0_clk = clk;
            RM1_clk = 1'bx;
            RM0_data = data;
            RM1_data = 4'bx;
            result = RM0_result;
        end else if (RM1_active)begin
            RM1_clk = clk;
            RM0_clk = 1'bx;
            RM1_data = data;
            RM0_data = 4'bx;
            result = RM1_result;
        end else begin
            RM0_clk = 1'bx;
            RM1_clk = 1'bx;
            RM0_data = 4'bx;
            RM1_data = 4'bx;
            result <= 4'bx;
        end
    end

//---------------------------------------------
//        Instantiating all RMs in RR
//---------------------------------------------
    arith_adder RM0 (
        .clk   ( RM0_clk ),
        .data   ( RM0_data ),
        .result   ( RM0_result )
    );
    arith_subtractor RM1 (
        .clk   ( RM1_clk ),
        .data   ( RM1_data ),
        .result   ( RM1_result )
    );
endmodule
