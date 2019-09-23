
set_property top count_up [current_fileset]
update_compile_order -fileset sources_1
synth_design -rtl -name rtl_1
refresh_design

#set a [get_cells -hier -filter {PRIMITIVE_TYPE=~ RTL_REGISTER.flop.RTL_REG}]
#puts $a
#puts [lindex $a 2]

set raw_reg_list [all_registers]
set raw_reg_list [lsort $raw_reg_list]
set reg_list {}
set pre_reg [lindex $raw_reg_list 0]
for {set i 0}  {$i < [llength $raw_reg_list] } {incr i} {
    set curr_reg [lindex $raw_reg_list $i]
    set curr_reg [split $curr_reg reg]
    set curr_reg [lindex $curr_reg 0]
    regsub {_$} $curr_reg {} curr_reg
    lappend reg_list $curr_reg
}

set counters {}
foreach item $reg_list {
    dict incr counters $item
}
dict for {item count} $counters {
    puts "${item}: $count"
}

set reg_list [lsort -unique $reg_list]
set force_list {}
for {set j 0}  {$j < [llength $reg_list] } {incr j} {
    lappend force_list [regsub / [lindex $reg_list $j] . ]
}
