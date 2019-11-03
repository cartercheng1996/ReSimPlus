# ----------------Setup the file write --------------------
proc OutFile_ICAP_VIRTEX4_WRAPPER_TOP {filePath} {
    set fp [open $filePath w+]
    puts $fp "/****************************************************************************************************
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
****************************************************************************************************/"
    puts $fp "\n`timescale 1ns/1ps\n"
    puts $fp "//---------------------------------------------
//           Instantiating I/O port
//---------------------------------------------"

    puts $fp "module ICAP_VIRTEX4_WRAPPER"
    puts $fp "("
    puts $fp "    input             CLK   ,"
    puts $fp "    input             CE    ,"
    puts $fp "    input             WRITE ,"
    puts $fp "    input  \[31:0]     I     ,"
    puts $fp "    output \[31:0]     O     ,"
    puts $fp "    output            BUSY   "
    puts $fp ");"

    puts $fp "\n//---------------------------------------------
//            Instantiating Constant
//---------------------------------------------\n"

    puts $fp "    assign BUSY=0;"
    puts $fp "    `define SYNC        32'hAA995566"
    puts $fp "    `define NOP         32'h20000000"
    puts $fp "    `define FAR_WRITE   32'h30002001"
    puts $fp "    `define WCFG        32'h00000001"
    puts $fp "    `define DESYNC      32'h0000000D"

    puts $fp "\n//---------------------------------------------
//                     FSM
//---------------------------------------------\n"
    puts $fp "    parameter REST          = 3'b000; //0"
    puts $fp "    parameter ENTER_CFG     = 3'b001; //1"
    puts $fp "    parameter SEL_RM        = 3'b010; //2"
    puts $fp "    parameter FINISH_CFG    = 3'b011; //3"
    puts $fp "    parameter Start_CFG     = 3'b100; //4"

    puts $fp "    reg  \[31:0] CFG_INO   = 32'hxxxx_xxxx;"
    puts $fp "    reg  \[31:0] RR_RM_INO = 32'hxxxx_xxxx;"
    puts $fp "    reg  \[7:0]  RR_ID;"
    puts $fp "    reg  \[7:0]  RM_ID;"
    puts $fp "    reg  \[2:0]  curr_state = REST;\n"

    puts $fp "    always@(*) begin"
    puts $fp "        RR_ID \[7:0] = RR_RM_INO \[31:24];"
    puts $fp "        RM_ID \[7:0] = RR_RM_INO \[23:16];"
    puts $fp "    end\n"

    puts $fp "    assign O = 1'b0;\n"

    puts $fp "    always@(*)"
    puts $fp "    begin"
    puts $fp "        if (WRITE==0) begin"
    puts $fp "            case (curr_state)"
    puts $fp "                REST:           if (I == `SYNC) begin"
    puts $fp "                                    curr_state = ENTER_CFG;"
    puts $fp "                                end else begin"
    puts $fp "                                    curr_state = REST;"
    puts $fp "                                end\n"

    puts $fp "                ENTER_CFG:      if (I == `FAR_WRITE) begin"
    puts $fp "                                    curr_state = SEL_RM;"
    puts $fp "                                end else begin"
    puts $fp "                                    curr_state = ENTER_CFG;"
    puts $fp "                                end\n"

    puts $fp "                SEL_RM:         if (I == `FAR_WRITE) begin"
    puts $fp "                                    curr_state = SEL_RM;"
    puts $fp "                                end else begin"
    puts $fp "                                    curr_state = Start_CFG;"
    puts $fp "                                    CFG_INO = I;"
    puts $fp "                                end\n"

    puts $fp "                Start_CFG:      if (I == `WCFG) begin"
    puts $fp "                                    curr_state = FINISH_CFG;"
    puts $fp "                                end else begin"
    puts $fp "                                     curr_state = Start_CFG;"
    puts $fp "                                end\n"

    puts $fp "                FINISH_CFG:     if (I == `DESYNC) begin"
    puts $fp "                                    curr_state = REST;"
    puts $fp "                                    RR_RM_INO = CFG_INO;"
    puts $fp "                                end else begin"
    puts $fp "                                    curr_state = FINISH_CFG;"
    puts $fp "                                    RR_RM_INO \[31:24] = CFG_INO \[31:24];"
    puts $fp "                                    RR_RM_INO \[23:16] = 8'hff;"
    puts $fp "                                    RR_RM_INO \[15: 0] = CFG_INO \[15: 0];"
    puts $fp "                                end\n"

    puts $fp "                default:        curr_state = REST;"
    puts $fp "            endcase"
    puts $fp "        end else begin"
    puts $fp "        // read from icap, undefind behavior"
    puts $fp "        end"
    puts $fp "    end"

    puts $fp "\n//---------------------------------------------
// Include the un-elaborated section
//---------------------------------------------\n"
    puts $fp "   \`include \"ICAP_VIRTEX4_WRAPPER_SimOnly.v\"\n"
    puts $fp "         "
    puts $fp "         "
    puts $fp "         "
    puts $fp "endmodule"
    close $fp
}
