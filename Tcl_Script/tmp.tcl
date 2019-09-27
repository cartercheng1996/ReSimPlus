    set input_list {clk a[0] a[1] count_out[0] count_out[1] count_out[2] count_out[3] rst}
    set input_name_list {}

    for {set i 0}  {$i < [llength $input_list] } {incr i} {
        set curr_in [lindex $input_list $i]
        set curr_in [split $curr_in \[ ]
        set curr_in [lindex $curr_in 0]
        lappend new_input_list $curr_in
    }
    puts $new_input_list
    set counters {}
    set RM_input_list {}
    set RM_input_list_pin {}
    foreach item $new_input_list {
        dict incr counters $item
    }
    dict for {item count} $counters {
        lappend RM_input_list $item
        lappend RM_input_list_pin $count
    }
    puts $RM_input_list
    puts $RM_input_list_pin
