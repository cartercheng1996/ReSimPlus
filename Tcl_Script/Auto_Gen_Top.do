#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************


proc ReSimPlus_Auto_Generation {RR_MUX_name_list RM_name_list RM_SimB_Len_List Top Auto_Add_File_Flag RR_BB_name_list Testbench_DesignTop_hierachy_list} {

    set DEBUG  0


    # ----------------Setup the working path------------------
    set curr_dir [pwd]
    set ReSimPlus_path [string trim $curr_dir "*/Tcl_Script"]
    set ReSim_Artifact_path $ReSimPlus_path
    append ReSim_Artifact_path "/Generated_Artifact"
    set ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path $ReSim_Artifact_path
    append ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path "/ICAP_VIRTEX4_WRAPPER.v"
    set ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_SimOnly_path $ReSim_Artifact_path
    append ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_SimOnly_path "/ICAP_VIRTEX4_WRAPPER_SimOnly.v"
    set ReSim_Artifact_SimB_path $ReSim_Artifact_path
    append ReSim_Artifact_SimB_path "/SimB"
    set MEM_ini_File_Name "mem_bank.txt"

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
        return
    } else {
        file mkdir $ReSim_Artifact_path
    }
    if [catch { set retstr [file mkdir $ReSim_Artifact_SimB_path] } errmsg] {
        puts "Cannot create directory $ReSim_Artifact_SimB_path . due to error: $errmsg"
        puts "Exiting...."
        return
    } else {
        file mkdir $ReSim_Artifact_SimB_path
    }


    set curr_top $Top

    # ----------------create RM Mux for each RR-------------------
    source MUX_top.do
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
        if { $Auto_Add_File_Flag ==1 } {
            add_files -norecurse $ReSim_Artifact_MUX_path
            update_compile_order -fileset sources_1
        }
    }

    # -----------------create SimB------------------
    # Top function of the ReSimPlus SimB generation
    source SimB_generator.do
    set RR_num  [llength $RR_MUX_name_list]
    OutFile_SimB_TOP $ReSim_Artifact_SimB_path $RR_num $RM_name_list $RM_SimB_Len_List $MEM_ini_File_Name

    # -----------------create ICAP_V4--------------------
    source ICAP_VIRTEX4_WRAPPER.do
    OutFile_ICAP_VIRTEX4_WRAPPER_TOP $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path
    set fp [open $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_SimOnly_path w+]
    close $fp

    if { $Auto_Add_File_Flag ==1 } {
        add_files -norecurse $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path
    }

    update_compile_order -fileset sources_1
    refresh_design
    set_property top $curr_top [current_fileset]
    update_compile_order -fileset sources_1
    refresh_design
    synth_design -rtl -name rtl_1
    refresh_design

    source ICAP_VIRTEX4_WRAPPER_SimOnly.do
    OutFile_ICAP_VIRTEX4_WRAPPER_SimOnly_TOP $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_SimOnly_path $Testbench_DesignTop_hierachy_list $RM_name_list $Top $RR_MUX_name_list $RR_BB_name_list

    if { $Auto_Add_File_Flag ==1 } {
        update_compile_order -fileset sources_1
        refresh_design
        set_property top $curr_top [current_fileset]
        close_design
    }

    #Log: Do DRS tuturial to see if can reduce user input
    #Log: Check more case when more deep RM herichy


}
