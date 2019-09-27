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
  set_property top $top_name [current_fileset]
  update_compile_order -fileset sources_1
  synth_design -rtl -name rtl_1
  refresh_design
  return [get_path $RM_name]
}

proc RM_path {top_name RM_name} {
  set RM_path [get_RM_hier_path $top_name $RM_name]
  set min [string length [lindex $RM_path 0]]
  set min_path [lindex $RM_path 0]
  for {set i 0}  {$i < [llength $RM_path] } {incr i} {
    if {[string length [lindex $RM_path $i]] < $min} {
      set min [string length [lindex $RM_path $i]]
      set min_path [lindex $RM_path $i]
    }
  }

  set min_path [regsub / $min_path .]

  return $min_path
}

puts [RM_path top RM0]
#set work_directory [get_property DIRECTORY [current_project]] ;
#cd $work_directory ; puts -nonewline "Changing Directory to " ;
#pwd
