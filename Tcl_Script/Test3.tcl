
proc sum_index {my_list i_end} {
    set sum 0
    for {set i 0} {$i < $i_end} {incr i} {
        set sum [expr $sum + [lindex $my_list $i]]
    }
    return $sum
}



set filePath "C:/Users/chine/Desktop/ReSimPlus/Tcl_Script/test_out.v"
set fp [open $filePath w+]

set RM_num 2
set force_reg_name_list {count_out count up_0/out count_out count}
set force_reg_pin_list {4 8 8 4 8}
set force_reg_num_list {3 2}
set RM_hierachy_list {testbench top_0}
set curr_path {inst_count}

# signal_index {0 3 5 7}
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
close $fp
