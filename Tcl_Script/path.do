proc print_hier {my_instance depth} {

    set my_children [get_cells -quiet -hierarchical -filter "!IS_PRIMITIVE && (PARENT == $my_instance)"]
    puts $my_children
    foreach child $my_children {
        for {set i 0} {$i < $depth} { incr i} { puts -nonewline "--"}
        puts [get_property NAME $child]
        print_hier $child [expr {$depth + 1}]
    }
}

set depth 2
set my_instance "testbench"

print_hier $my_instance $depth
