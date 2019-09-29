proc mycompare {arg1 arg2} {
   return [expr [string length $arg1] - [string length $arg2]]
}

proc get_path {RM_name} {
  set path {}

  #set my_children [get_cells -quiet -hierarchical -filter "!IS_PRIMITIVE"]
  set my_children {icapi_0 inst_arith a/b/inst_count inst_op icapi_0/icap_0 inst_arith/RM0 inst_arith/RM1 a/b/inst_count/RM0 a/b/inst_count/RM1 a/b/inst_count/RM0/up_0 inst_op/RM0 inst_op/RM1 inst_op/RM2}
  for {set i 0}  {$i < [llength $my_children] } {incr i} {
    if {[ regexp $RM_name [lindex $my_children $i] ]} {
            lappend path [lindex $my_children $i]
    }
  }
  return $path
}

proc get_RM_hier_path {top_name RM_name} {
  #set_property top $top_name [current_fileset]
  #update_compile_order -fileset sources_1
  #synth_design -rtl -name rtl_1
  #refresh_design
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

puts [RM_path Top inst_count]

#set work_directory [get_property DIRECTORY [current_project]] ;
#cd $work_directory ; puts -nonewline "Changing Directory to " ;
#pwd
#get_property TOP [get_filesets sources_1]
