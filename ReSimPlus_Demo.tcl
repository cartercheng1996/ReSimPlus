#start_gui
set curr_dir [pwd]
cd $curr_dir
set memctrl_directory $curr_dir
append memctrl_directory "/testbench/memctrl.do"
source $memctrl_directory
set filePath $curr_dir
append filePath "/testbench/memctrl.sv"
set memtxt_path $curr_dir
append memtxt_path "/Generated_Artifact/SimB"
OutFile_Memctrl $filePath $memtxt_path
source ReSimPlus_Demo_project.tcl
set Tcl_Script_Directory $curr_dir
append Tcl_Script_Directory "/Tcl_Script"
cd $Tcl_Script_Directory
source User_Top.tcl
cd $curr_dir
set wcfg_directory $curr_dir
append wcfg_directory "/testbench_behav.wcfg"
add_files -fileset sim_1 -norecurse $wcfg_directory
set_property xsim.view $wcfg_directory [get_filesets sim_1]
launch_simulation
restart
run 1000us
