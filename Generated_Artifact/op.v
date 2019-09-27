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
module op 
(
   input   clk,
   input   [3:0] dataa,
   input   [3:0] datab,
   output reg [4:0] result
);

//---------------------------------------------
//   Instantiating reconfigurable MUX-Logic
//---------------------------------------------

    //RM0 Interface
    reg       RM0_active;
    reg       RM0_clk;
    reg [3:0] RM0_dataa;
    reg [3:0] RM0_datab;
    reg [4:0] RM0_result;

    //RM1 Interface
    reg       RM1_active;
    reg       RM1_clk;
    reg [3:0] RM1_dataa;
    reg [3:0] RM1_datab;
    reg [4:0] RM1_result;

    //RM2 Interface
    reg       RM2_active;
    reg       RM2_clk;
    reg [3:0] RM2_dataa;
    reg [3:0] RM2_datab;
    reg [4:0] RM2_result;


//---------------------------------------------
// Instantiating MUX connecting all RMs in RR
//---------------------------------------------

    always@(*) begin
        if (RM0_active) begin
            RM0_clk = clk;
            RM1_clk = 1'bx;
            RM2_clk = 1'bx;
            RM0_dataa = dataa;
            RM1_dataa = 4'bx;
            RM2_dataa = 4'bx;
            RM0_datab = datab;
            RM1_datab = 4'bx;
            RM2_datab = 4'bx;
            result = RM0_result;
        end else if (RM1_active)begin
            RM1_clk = clk;
            RM0_clk = 1'bx;
            RM2_clk = 1'bx;
            RM1_dataa = dataa;
            RM0_dataa = 4'bx;
            RM2_dataa = 4'bx;
            RM1_datab = datab;
            RM0_datab = 4'bx;
            RM2_datab = 4'bx;
            result = RM1_result;
        end else if (RM2_active)begin
            RM2_clk = clk;
            RM0_clk = 1'bx;
            RM1_clk = 1'bx;
            RM2_dataa = dataa;
            RM0_dataa = 4'bx;
            RM1_dataa = 4'bx;
            RM2_datab = datab;
            RM0_datab = 4'bx;
            RM1_datab = 4'bx;
            result = RM2_result;
        end else begin
            RM0_clk = 1'bx;
            RM1_clk = 1'bx;
            RM2_clk = 1'bx;
            RM0_dataa = 4'bx;
            RM1_dataa = 4'bx;
            RM2_dataa = 4'bx;
            RM0_datab = 4'bx;
            RM1_datab = 4'bx;
            RM2_datab = 4'bx;
            result <= 4'hx;
        end
    end

//---------------------------------------------
//        Instantiating all RMs in RR
//---------------------------------------------
    op_sum RM0 (
        .clk   ( RM0_clk ),
        .dataa   ( RM0_dataa ),
        .datab   ( RM0_datab ),
        .result   ( RM0_result )
    );
    op_difference RM1 (
        .clk   ( RM1_clk ),
        .dataa   ( RM1_dataa ),
        .datab   ( RM1_datab ),
        .result   ( RM1_result )
    );
    op_compare RM2 (
        .clk   ( RM2_clk ),
        .dataa   ( RM2_dataa ),
        .datab   ( RM2_datab ),
        .result   ( RM2_result )
    );
endmodule
