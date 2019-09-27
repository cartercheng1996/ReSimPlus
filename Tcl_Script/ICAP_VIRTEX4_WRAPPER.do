# ----------------Signal auto-assignment ------------------
proc assign_path {fp RM_hierachy_list} {
    for {set i 0}  {$i < [llength $RM_hierachy_list] } {incr i} {
        puts -nonewline $fp [lindex $RM_hierachy_list $i]
        puts -nonewline $fp "."
    }
}

# ----------------Signal auto-assignment ------------------
proc get_all_force_reg {RM_name} {
    set_property top $RM_name [current_fileset]
    update_compile_order -fileset sources_1
    synth_design -rtl -name rtl_1
    refresh_design

    #set a [get_cells -hier -filter {PRIMITIVE_TYPE=~ RTL_REGISTER.flop.RTL_REG}]
    #puts $a
    #puts [lindex $a 2]

    set raw_reg_list [all_registers]
    set raw_reg_list [lsort $raw_reg_list]
    set reg_list {}
    for {set i 0}  {$i < [llength $raw_reg_list] } {incr i} {
        set curr_reg [lindex $raw_reg_list $i]
        set curr_reg [split $curr_reg reg]
        set curr_reg [lindex $curr_reg 0]
        regsub {_$} $curr_reg {} curr_reg
        lappend reg_list $curr_reg
    }

    return $reg_list

}


# ----------------Setup the file write --------------------
proc OutFile_ICAP_VIRTEX4_WRAPPER_TOP {filePath RM_hierachy_list RM_num RM_Defualt RM_name_list} {

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
    puts $fp "\n\n`timescale 1ns/1ps\n"
    puts $fp "\n//---------------------------------------------
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
    puts $fp "    `define DESYNC      32'h0000000D"

    puts $fp "\n//---------------------------------------------
//                     FSM
//---------------------------------------------\n"
    puts $fp "    reg  \[31:0] CFG_INO = 32'h0;"
    puts $fp "    reg  \[7:0]  RR_ID;"
    puts $fp "    reg  \[7:0]  RM_ID;\n"
    puts $fp "    typedef enum logic \[2:0] {REST,ENTER_CFG,SEL_RM,FINISH_CFG} State;"
    puts $fp "    State curr_state = REST;\n"
    puts $fp "    assign RR_ID = CFG_INO \[31:24];"
    puts $fp "    assign RM_ID = CFG_INO \[23:16];"
    puts $fp "    assign O = 1'b0;"

    puts $fp "    always_comb"
    puts $fp "    begin : FSM"
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
    puts $fp "                                    curr_state = FINISH_CFG;"
    puts $fp "                                    CFG_INO = I;"
    puts $fp "                                end\n"

    puts $fp "                FINISH_CFG:     if (I == `DESYNC) begin"
    puts $fp "                                    curr_state = REST;"
    puts $fp "                                end else begin"
    puts $fp "                                    curr_state = FINISH_CFG;"
    puts $fp "                                end\n"
    puts $fp "                default:        curr_state = REST;"
    puts $fp "            endcase"
    puts $fp "        end else begin"
    puts $fp "        // read from icap, undefind behavior"
    puts $fp "        end"
    puts $fp "    end"

    puts $fp "\n//---------------------------------------------
// Update MUX_TOP.do generated file MUX-signal
//---------------------------------------------\n"

    puts $fp "    always_comb"
    puts $fp "    begin: MUX"

    for {set j 0}  {$j <$RM_num } {incr j} {
        if {$j == 0} {
    	    puts $fp "        if (RM_ID == 8'h00) begin"
        } else {
            puts $fp "        end else if (RM_ID == 8'h0$j) begin"
        }

	    for {set i 0}  {$i <$RM_num } {incr i} {
            puts -nonewline $fp "            "
            assign_path $fp $RM_hierachy_list
            puts -nonewline $fp "RM$i\_active <="
            if {$i == $j} {
                puts $fp "1;"
            } else {
                puts $fp "0;"
            }
        }
    }
    puts $fp "        end else begin"
    puts $fp "            // defualt RM"
    for {set i 0}  {$i <$RM_num } {incr i} {
        puts -nonewline $fp "            "
        assign_path $fp $RM_hierachy_list
        puts -nonewline $fp "RM$i\_active <="
        if {$i == $RM_Defualt} {
            puts $fp "1;"
        } else {
            puts $fp "0;"
        }
    }
    puts $fp "        end"
    puts $fp "    end"



    puts $fp "\n//---------------------------------------------
//           State-restoration part
//---------------------------------------------"
    puts $fp "    always_comb"
    puts $fp "    begin: force_signal"
        for {set j 0}  {$j <$RM_num } {incr j} {

            if {$j == 0} {
                puts $fp "        if (RM_ID == 8'h00) begin"
            } else {
                puts $fp "        end else if (RM_ID == 8'h0$j) begin"
            }

            for {set i 0}  {$i <$RM_num } {incr i} {
                set force_reg_list [get_all_force_reg [lindex $RM_name_list $i]]

                set counters {}
                set RM_reg_list {}
                set RM_reg_list_pin {}
                foreach item $force_reg_list {
                    dict incr counters $item
                }
                dict for {item count} $counters {
                    #puts $fp "${item}: $count"
                    lappend RM_reg_list $item
                    lappend RM_reg_list_pin $count
                }

                #set RM_reg_list [lsort -unique $RM_reg_list]
                set force_list {}

                for {set l 0}  {$l < [llength $RM_reg_list] } {incr l} {
                    lappend force_list [regsub / [lindex $RM_reg_list $l] . ]
                }

                for {set k 0}  {$k <[llength $force_list] } {incr k} {
                    puts -nonewline $fp "            "
                    if {$i!=$j} {
                        puts -nonewline $fp "force     "
                    } else {
                        puts -nonewline $fp "release   "
                    }
                    assign_path $fp $RM_hierachy_list
                    puts -nonewline $fp "RM$i\."
                    puts -nonewline $fp [lindex $force_list $k]
                    if {$i!=$j} {
                        puts -nonewline $fp "="
                        puts -nonewline $fp [lindex $RM_reg_list_pin $k]
                        puts -nonewline $fp "'dx"
                    }
                    puts  $fp ";"
                }
            }
    }
    puts $fp "        end else begin"
    puts $fp "            // defualt RM"
    puts $fp "        end"
    puts $fp "    end"

    puts $fp "endmodule"
    close $fp

}
