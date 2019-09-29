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
module count 
(
   input   clk,
   input   rst,
   output reg [3:0] count_out
);

//---------------------------------------------
//   Instantiating reconfigurable MUX-Logic
//---------------------------------------------

    //RM0 Interface
    reg       RM0_active;
    reg       RM0_clk;
    reg       RM0_rst;
    wire [3:0] RM0_count_out;

    //RM1 Interface
    reg       RM1_active;
    reg       RM1_clk;
    reg       RM1_rst;
    wire [3:0] RM1_count_out;


//---------------------------------------------
// Instantiating MUX connecting all RMs in RR
//---------------------------------------------

    always@(*) begin
        if (RM0_active) begin
            RM0_clk = clk;
            RM1_clk = 1'bx;
            RM0_rst = rst;
            RM1_rst = 1'bx;
            count_out = RM0_count_out;
        end else if (RM1_active)begin
            RM1_clk = clk;
            RM0_clk = 1'bx;
            RM1_rst = rst;
            RM0_rst = 1'bx;
            count_out = RM1_count_out;
        end else begin
            RM0_clk = 1'bx;
            RM1_clk = 1'bx;
            RM0_rst = 1'bx;
            RM1_rst = 1'bx;
            count_out <= 4'bx;
        end
    end

//---------------------------------------------
//        Instantiating all RMs in RR
//---------------------------------------------
    count_up RM0 (
        .clk   ( RM0_clk ),
        .rst   ( RM0_rst ),
        .count_out   ( RM0_count_out )
    );
    count_down RM1 (
        .clk   ( RM1_clk ),
        .rst   ( RM1_rst ),
        .count_out   ( RM1_count_out )
    );
endmodule
