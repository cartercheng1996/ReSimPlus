proc get_all_force_reg {RM_name} {
    #set_property top $RM_name [current_fileset]
    #update_compile_order -fileset sources_1
    #synth_design -rtl -name rtl_1
    #refresh_design

    #set a [get_cells -hier -filter {PRIMITIVE_TYPE=~ RTL_REGISTER.flop.RTL_REG}]
    #puts $a
    #puts [lindex $a 2]

    set raw_reg_list [all_registers]

    set raw_reg_list [lsort $raw_reg_list]
    puts $raw_reg_list
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


set reg_list [get_all_force_reg count_up]
set force_reg_name_list {}
set force_reg_pin_list {}
set force_reg_num_list {}
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

puts $force_reg_name_list
puts $force_reg_pin_list
puts $force_reg_num_list
