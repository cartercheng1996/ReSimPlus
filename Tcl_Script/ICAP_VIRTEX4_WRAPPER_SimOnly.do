#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************
# ----------------Helpper function get herichy path------------------

proc sum_index {my_list i_end} {
    set sum 0
    for {set i 0} {$i < $i_end} {incr i} {
        set sum [expr $sum + [lindex $my_list $i]]
    }
    return $sum
}

proc mycompare {arg1 arg2} {
   return [expr [string length $arg1] - [string length $arg2]]
}

proc get_path {RM_name} {
  set path {}
  set my_children [get_cells -quiet -hierarchical -filter "!IS_PRIMITIVE"]
  for {set i 0}  {$i < [llength $my_children] } {incr i} {
    if {[ regexp $RM_name [lindex $my_children $i] ]} {
            lappend path [lindex $my_children $i]
    }
  }
  return $path
}

proc get_RM_hier_path {top_name RM_name} {
  if {[get_property TOP [get_filesets sources_1]] != $top_name} {
        set_property top $top_name [current_fileset]
        update_compile_order -fileset sources_1
        synth_design -rtl -name rtl_1
        refresh_design

  }
  return [get_path $RM_name]
}

proc RM_path {top_name RM_name} {
  set RM_path [get_RM_hier_path $top_name $RM_name]
  set RM_path [lsort -command mycompare $RM_path]
  set min [llength [split [lindex $RM_path 0] / ] ]
  set min_path {}
  for {set i 0}  {$i < [llength $RM_path] } {incr i} {
    if {[llength [split [lindex $RM_path $i] / ]] == $min} {
      lappend min_path  [string map {/ .} [lindex $RM_path $i]]
    }
  }
  return $min_path
}


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

        for {set j [expr [string length $curr_reg]-1]}  { $j >= 0 } {incr j -1} {
            set curr_char [string index $curr_reg $j]
            if {$curr_char == {[} } {
                break
            }
        }
        set curr_reg [string range $curr_reg 0 [expr $j-1]]

        for {set k [expr [string length $curr_reg]-1]}  { $k >= 0 } {incr k -1} {
            set curr_char [string index $curr_reg $k]
            if {$curr_char == {_} } {
                break
            }
        }
        set curr_reg [string range $curr_reg 0 [expr $k-1]]
        lappend reg_list $curr_reg
    }
    return $reg_list
}

# ----------------Setup the file write --------------------
proc OutFile_ICAP_VIRTEX4_WRAPPER_SimOnly_TOP {filePath RM_hierachy_list RM_name_list Top RR_list RR_BB_name_list} {

    set fp [open $filePath w+]
    puts $fp "/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia

This is ReSimPlus auto generated file, use for simulation only!

The purpose of this file is to separate the simulation-only code-section. (Which can't be Sync. or elaborated)
****************************************************************************************************/"
    puts $fp "//---------------------------------------------
// Update MUX_TOP.do generated file MUX-signal
//---------------------------------------------"

    puts $fp "    always@(*)"
    puts $fp "    begin"


    for {set k 0}  {$k < [llength $RM_name_list] } {incr k} {
        set RM_num [llength [lindex $RM_name_list $k]]
        set RR_name_tmp [lindex $RR_BB_name_list $k]
        set curr_path [RM_path $Top $RR_name_tmp]
        if {$k == 0} {
                puts $fp "        if (RR_ID == 8'd0) begin"
            } else {
                puts $fp "        end else if (RR_ID == 8'd$k) begin"
        }
        for {set j 0}  {$j < $RM_num } {incr j} {

            if {$j == 0} {
                puts $fp "            if (RM_ID == 8'd0) begin"
            } else {
                puts $fp "            end else if (RM_ID == 8'd$j) begin"
            }

            for {set i 0}  {$i <$RM_num } {incr i} {
                set path $RM_hierachy_list
                puts -nonewline $fp "                "
                assign_path $fp [lappend path $curr_path]
                puts -nonewline $fp "RM$i\_active <="
                if {$i == $j} {
                    puts $fp "1;"
                } else {
                    puts $fp "0;"
                }
            }
        }
        puts $fp "            end"
    }
    puts $fp "        end"
    puts $fp "    end"

    puts $fp "\n//---------------------------------------------
//           State-restoration part
//---------------------------------------------"
    puts $fp "    always@(*)"
    puts $fp "    begin"

    for {set k 0}  {$k < [llength $RM_name_list] } {incr k} {
        set curr_RR_RMs_list [lindex $RM_name_list $k]
        set RM_num [llength $curr_RR_RMs_list]

        set RM_num [llength [lindex $RM_name_list $k]]
        set RR_name_tmp [lindex $RR_BB_name_list $k]
        set curr_path [RM_path $Top $RR_name_tmp]

        if {$k == 0} {
                puts $fp "        if (RR_ID == 8'd0) begin"
            } else {
                puts $fp "        end else if (RR_ID == 8'd$k) begin"
        }

        set force_reg_name_list {}
        set force_reg_pin_list {}
        set force_reg_num_list {}

        for {set j 0}  {$j < $RM_num } {incr j} {
            set curr_RM [lindex $curr_RR_RMs_list $j]
            set reg_list [get_all_force_reg $curr_RM]
            set counter {}
            set num 0
            foreach item $reg_list {
                dict incr counter $item
            }
            dict for {item count} $counter {
                lappend force_reg_name_list $item
                lappend force_reg_pin_list $count
                incr num
            }
            lappend force_reg_num_list $num
        }

        set signal_index {}
        set counta 0
        foreach x $force_reg_num_list {
            lappend signal_index [sum_index $force_reg_num_list $counta]
            incr counta
        }
        puts $signal_index

        for {set i 0}  {$i < $RM_num } {incr i} {
            if {$i == 0} {
                puts $fp "            if (RM_ID == 8'd0) begin"
            } else {
                puts $fp "            end else if (RM_ID == 8'd$i) begin"
            }

            for {set a 0}  {$a < $RM_num } {incr a} {
                set start_index [lindex $signal_index $a]
                set counter 0
                for {set b 0}  {$b < [lindex $force_reg_num_list $a] } {incr b} {
                    puts -nonewline $fp "                "
                    if {$a!=$i} {
                        puts -nonewline $fp "force     "
                    } else {
                        puts -nonewline $fp "release   "
                    }

                    set path $RM_hierachy_list
                    assign_path $fp [lappend path $curr_path]
                    puts -nonewline $fp "RM$a\."
                    puts -nonewline $fp [string map {/ .} [lindex $force_reg_name_list [expr $start_index + $counter]]]
                    if {$a!=$i} {
                        puts -nonewline $fp "="
                        puts -nonewline $fp [lindex $force_reg_pin_list [expr $start_index + $counter]]
                        puts -nonewline $fp "'dx"
                    }
                    puts  $fp ";"
                    incr counter
                }
            }
        }
        puts $fp "            end"

    }
    puts $fp "        end"
    puts $fp "    end"
    close $fp

}
