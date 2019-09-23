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

    reg  [31:0] CFG_INO = 32'h0;
    reg  [7:0]  RR_ID;
    reg  [7:0]  RM_ID;

    typedef enum logic [2:0] {REST,ENTER_CFG,SEL_RM,FINISH_CFG} State;
    State curr_state = REST;

    assign RR_ID = CFG_INO [31:24];
    assign RM_ID = CFG_INO [23:16];
    assign O = 1'b0;
    always_comb
    begin : FSM
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
// Update MUX_TOP.do generated file MUX-signal
//---------------------------------------------

    always_comb
    begin: MUX
        if (RM_ID == 8'h00) begin
            testbench.top_0.inst_count.RM0_active <=1;
            testbench.top_0.inst_count.RM1_active <=0;
        end else if (RM_ID == 8'h01) begin
            testbench.top_0.inst_count.RM0_active <=0;
            testbench.top_0.inst_count.RM1_active <=1;
        end else begin
            // defualt RM
            testbench.top_0.inst_count.RM0_active <=1;
            testbench.top_0.inst_count.RM1_active <=0;
        end
    end

//---------------------------------------------
//           State-restoration part
//---------------------------------------------

    `include 

    always_comb
    begin: force_signal
        if (RM_ID == 8'h00) begin
            release   testbench.top_0.inst_count.RM0.count_out;
            release   testbench.top_0.inst_count.RM0.count;
            release   testbench.top_0.inst_count.RM0.up_0.out;
            force     testbench.top_0.inst_count.RM1.count_out=4'dx;
            force     testbench.top_0.inst_count.RM1.count=8'dx;
        end else if (RM_ID == 8'h01) begin
            force     testbench.top_0.inst_count.RM0.count_out=4'dx;
            force     testbench.top_0.inst_count.RM0.count=8'dx;
            force     testbench.top_0.inst_count.RM0.up_0.out=8'dx;
            release   testbench.top_0.inst_count.RM1.count_out;
            release   testbench.top_0.inst_count.RM1.count;
        end else begin
            // defualt RM
        end
    end
endmodule
