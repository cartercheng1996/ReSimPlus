#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************
set DEBUG  0
# ----------------Setup the working path------------------
set curr_dir [pwd]
set ReSimPlus_path [string trim $curr_dir "*/Tcl_Script"]
set ReSim_Artifact_path $ReSimPlus_path
append ReSim_Artifact_path "/Generated_Artifact"
set ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path $ReSim_Artifact_path
append ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path "/ICAP_VIRTEX4_WRAPPER.sv"
set ReSim_Artifact_SimB_path $ReSim_Artifact_path
append ReSim_Artifact_SimB_path "/SimB"

# -----------------create Debug Info print------------------
if {$DEBUG == 1} {
    puts "ReSimPlus_path:          $ReSimPlus_path"
    puts "ReSim_Artifact_path:     $ReSim_Artifact_path"
    puts "ReSim_Artifact_MUX_path: $ReSim_Artifact_MUX_path"
    puts "ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path: $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path"
    puts "ReSim_Artifact_SimB_path: $ReSim_Artifact_SimB_path"
}

# --------------------create new directory-------------------
if [catch { set retstr [file mkdir $ReSim_Artifact_path] } errmsg] {
    puts "Cannot create directory $ReSim_Artifact_path . due to error: $errmsg"
    puts "Exiting...."
    exit
} else {
   file mkdir $ReSim_Artifact_path
}
if [catch { set retstr [file mkdir $ReSim_Artifact_SimB_path] } errmsg] {
    puts "Cannot create directory $ReSim_Artifact_SimB_path . due to error: $errmsg"
    puts "Exiting...."
    exit
} else {
   file mkdir $ReSim_Artifact_SimB_path
}

source MUX_top.do
# -------------------Important Notice-----------------------
#   We assume here each RM in a RR has same port interface
# ----------------------------------------------------------

# -------------------User provided info---------------------
# RR_MUX_name_list is the file_name or instance_name of the MUX in each RR
# e.g. if RR0 has 2 RMs (count_up and count_down), RR1 also has 2RMs
#      (arith_add and arith_sub) and RR2 has 3RMs (op_cmp, op_sum and op_diff)
#      then RR_MUX_name is {count arith op} which also indicates there are 3RRs
set RR_MUX_name_list {count arith op}
#set RR_MUX_name_list {count}

# RM_name_list is the list of list (nest list) which provide the RM_name info of
# each RR, the order corespond to its RR number.
# e.g. {{count_up count_down} {arith_adder arith_subtractor}} means RR0 countain
#      two RMs "count_up and count_down" etc.
set RM_name_list { {count_up count_down} {arith_adder arith_subtractor} {op_sum op_difference op_compare}}



for {set i 0 } {$i < [llength $RR_MUX_name_list]} {incr i} {
    set curr_RM_list [lindex $RM_name_list $i]
    set RM_num [llength $curr_RM_list ]
    set curr_RM_name  [lindex $curr_RM_list 0]
    set IO_type  {}
    set IO_pin {}
    set IO_name {}
    set  ReSim_Artifact_MUX_path $ReSim_Artifact_path
    append ReSim_Artifact_MUX_path /[lindex $RR_MUX_name_list $i].v
    set FileName [lindex $RR_MUX_name_list $i]

    set_property top $curr_RM_name [current_fileset]
    update_compile_order -fileset sources_1
    synth_design -rtl -name rtl_1
    refresh_design

    set input_list [all_inputs]
    set new_input_list {}

    for {set k 0}  {$k < [llength $input_list] } {incr k} {
        set curr_in [lindex $input_list $k]
        set curr_in [split $curr_in \[ ]
        set curr_in [lindex $curr_in 0]
        lappend new_input_list $curr_in
    }

    set counters {}


    foreach item $new_input_list {
        dict incr counters $item
    }
    dict for {item count} $counters {
        lappend IO_name $item
        lappend IO_pin [expr $count-1]
        lappend IO_type input
    }

    set output_list [all_outputs]
    set new_output_list {}

    for {set h 0}  {$h < [llength $output_list] } {incr h} {
        set curr_out [lindex $output_list $h]
        set curr_out [split $curr_out \[ ]
        set curr_out [lindex $curr_out 0]
        lappend new_output_list $curr_out
    }

    set countersa {}

    foreach itemb $new_output_list {
        dict incr countersa $itemb
    }
    dict for {itemb counta} $countersa {
        lappend IO_name $itemb
        lappend IO_pin [expr $counta-1]
        lappend IO_type output
    }

    if {$DEBUG == 2} {
        puts $IO_type
        puts $IO_pin
        puts $IO_name
        puts $ReSim_Artifact_MUX_path
    }

    # Top function of the ReSimPlus MUX
    # If we have RRs {count arith op}, then will generate count.v arith.v and op.v

    OutFile_MUX_TOP $ReSim_Artifact_MUX_path $IO_type $IO_pin $IO_name $FileName $RM_num $curr_RM_list
}


#set RM_hierachy_list {testbench top_0 inst_count}
#set RM_Defualt 0
#set RM_SimB_Len 32
#set MEM_ini_File_Name "mem_bank.txt"
#
# -----------------Auto Generation Step--------------------
#
#source ICAP_VIRTEX4_WRAPPER.do
#source SimB_generator.do



#
#set RR_num  [llength $RR_MUX_name_list]
#
#OutFile_SimB_TOP $ReSim_Artifact_SimB_path $RR_num $RM_num $RM_SimB_Len $MEM_ini_File_Name
#OutFile_ICAP_VIRTEX4_WRAPPER_TOP $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path $RM_hierachy_list $RM_num $RM_Defualt $RM_name
#Log: The Vivado Tcl has issue keep as global variable
