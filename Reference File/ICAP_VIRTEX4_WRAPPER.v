/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia

This is ReSimPlus auto generated file, use for simulation only!

The purpose of this file is to simulate the ICAP bitstream traffic. It acts as the auto responser for
the inputing bitstream data, base on the bitstream contents, it will output and update the MUX control
signal in the MUX_TOP.sv file. Therefore, it provides users a chance to verify the reconfiguration
datapath (e.g. User design ICAPI port and bus) without needing to modify the original design
(e.g. insert MUX).
****************************************************************************************************/


`timescale 1ns/1ps


//---------------------------------------------
//           Instantiating I/O port
//---------------------------------------------
module ICAP_VIRTEX4_WRAPPER
(
    input             CLK   ,
    input             CE    ,
    input             WRITE ,
    input  [31:0]     I     ,
    output [31:0]     O     ,
    output            BUSY
);

//---------------------------------------------
//            Instantiating Constant
//---------------------------------------------

    assign BUSY=0;
    `define SYNC        32'hAA995566
    `define NOP         32'h20000000
    `define FAR_WRITE   32'h30002001
    `define DESYNC      32'h0000000D

//---------------------------------------------
//                     FSM
//---------------------------------------------

    parameter REST          = 2'b00;
    parameter ENTER_CFG     = 2'b01;
    parameter SEL_RM        = 2'b10;
    parameter FINISH_CFG    = 2'b11;

    reg  [31:0] CFG_INO   = 32'hffff_ffff;
    reg  [31:0] RR_RM_INO = 32'hffff_ffff;
    reg  [7:0]  RR_ID;
    reg  [7:0]  RM_ID;
    reg  [1:0]  curr_state = REST;

    always@(*) begin
        if (RR_RM_INO  != 32'hffff_ffff) begin
            RR_ID [7:0] = RR_RM_INO [31:24];
            RM_ID [7:0] = RR_RM_INO [23:16];
        end
    end
    assign O = 1'b0;
    always@(*)
    begin
        if (WRITE==0) begin
            case (curr_state)
                REST:           if (I == `SYNC) begin
                                    curr_state = ENTER_CFG;
                                end else begin
                                    curr_state = REST;
                                end

                ENTER_CFG:      if (I == `FAR_WRITE) begin
                                    curr_state = SEL_RM;
                                end else begin
                                    curr_state = ENTER_CFG;
                                end

                SEL_RM:         if (I == `FAR_WRITE) begin
                                    curr_state = SEL_RM;
                                end else begin
                                    curr_state = FINISH_CFG;
                                    CFG_INO = I;
                                end

                FINISH_CFG:     if (I == `DESYNC) begin
                                    curr_state = REST;
                                    RR_RM_INO = CFG_INO;
                                end else begin
                                    curr_state = FINISH_CFG;
                                end

                default:        curr_state = REST;
            endcase
        end else begin
        // read from icap, undefind behavior
        end
    end

//---------------------------------------------
// Include the un-elaborated section
//---------------------------------------------

    `include "ICAP_VIRTEX4_WRAPPER_SimOnly.v"

endmodule
