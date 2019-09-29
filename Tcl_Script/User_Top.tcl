#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************
source Auto_Gen_Top.do

# -------------------Important Notice-----------------------
#   1. We assume here each RM in a RR has same port interface
#   2. We assume here each RM's bitstream length in each RR
#      is same, since the area of each RR is fixed value when
#      doing the on-board RR planing.
#   3. We assume here each RR has "UNIQUE" black-box instance name.
#   4. The ReSimPlus Auto-Generated file will be output to the
#   same directory where you put the Tcl_Script folder
# ----------------------------------------------------------

# -------------------User provided info---------------------
# Specify the modules hierachy from your testbench to your design top
set Testbench_DesignTop_hierachy_list {testbench top_0}
# RR_MUX_name_list is the file_name or instance_name of the MUX in each RR
# e.g. if RR0 has 2 RMs (count_up and count_down), RR1 also has 2RMs
#      (arith_add and arith_sub) and RR2 has 3RMs (op_cmp, op_sum and op_diff)
#      then RR_MUX_name is {count arith op} which also indicates there are 3RRs
set RR_MUX_name_list {count arith op}

# It is your RR Black Box instance name corresponding to RR_MUX_name_list
set RR_BB_name_list {inst_count inst_arith inst_op}

# RM_name_list is the list of list (nest list) which provide the RM_name info of
# each RR, the order corespond to its RR number.
# e.g. {{count_up count_down} {arith_adder arith_subtractor}} means RR0 countain
#      two RMs "count_up and count_down" etc.
set RM_name_list { {count_up count_down} {arith_adder arith_subtractor} {op_sum op_difference op_comparer}}

# The RM_bitstream_list is the length of the real configuration bitstream store in memory.
# If RM_bitstream_list is {32 64 128}, then it means RR0 has fixed RM_bitstream length = 32 etc.
set RM_bitstream_list {32 64 128}

# Your Top module of your DRS design
set Top_Design_module_name "top"

# This flag will determine if the Auto-Generator will or will not add the Auto-Generated Simulation-Only file to your current vivado project
# 0: will not do auto-add 1: will do auto-add
# If you chose do not auto add, please manually add the generated file in folder:
# "Generated_Aritifact" and if elaboration is not auto-done please do it manually,
# otherwise it will cause an error in following steps.
set Auto_Add_File_Flag 1

# This will ensure you enter the correct format of RM_name_list
if { [llength $RR_MUX_name_list] != [llength $RM_name_list] } {
    puts "ERROR: Tuple number don't match of two user input lists"
    puts "Please ensure: RR_MUX_name_list is in the format {a b c}, where a b and c are RRs name"
    puts "Please ensure: RM_name_list is in the format {{a b} {c d} {e f g}}, where a b c d e f g are RMs name of each correspoding RR of {a b c}"
    puts "Exiting due to error"
    return
} else {
    # This is the top function of the Auto_Generation
    ReSimPlus_Auto_Generation $RR_MUX_name_list $RM_name_list $RM_bitstream_list $Top_Design_module_name $Auto_Add_File_Flag $RR_BB_name_list $Testbench_DesignTop_hierachy_list
}
