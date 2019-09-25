set DEBUG  0
# ----------------Setup the working path------------------
set curr_dir [pwd]
set ReSimPlus_path [string trim $curr_dir "*/Tcl_Script"]
set ReSim_Artifact_path $ReSimPlus_path
append ReSim_Artifact_path "/Generated_Artifact"
set  ReSim_Artifact_MUX_path $ReSim_Artifact_path
append ReSim_Artifact_MUX_path "/count.sv"
set ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path $ReSim_Artifact_path
append ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path "/ICAP_VIRTEX4_WRAPPER.sv"
set ReSim_Artifact_SimB_path $ReSim_Artifact_path
append ReSim_Artifact_SimB_path "/SimB"

if {$DEBUG == 1} {
    puts "ReSimPlus_path:          $ReSimPlus_path"
    puts "ReSim_Artifact_path:     $ReSim_Artifact_path"
    puts "ReSim_Artifact_MUX_path: $ReSim_Artifact_MUX_path"
    puts "ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path: $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path"
    puts "ReSim_Artifact_SimB_path: $ReSim_Artifact_SimB_path"
}

# -----------------create new directory------------------
if [catch { set retstr [file mkdir $ReSim_Artifact_path] } errmsg] {
    puts "Cannot create directory $ReSim_Artifact_path . due to error: $errmsg"
    puts "Exiting...."
    exit
} else {
   file mkdir $ReSim_Artifact_path
}
if [catch { set retstr [file mkdir $ReSim_Artifact_SimB_path] } errmsg] {
    puts "Cannot create directory $ReSim_Artifact_SimB_path . due to error: $errmsg"
    puts "Exiting...."
    exit
} else {
   file mkdir $ReSim_Artifact_SimB_path
}

# --------------Setup port decalration info---------------
set FileName "count"
set RR_num   1
set RM_num   2
set IO_type  {input input output}
set IO_pin   {0 0 3}
set IO_name  {clk rst count_out}
set RM_name  {count_up count_down}
set RM_hierachy_list {testbench top_0 inst_count}
set RM_Defualt 0
set RM_SimB_Len 32
set MEM_ini_File_Name "mem_bank.txt"
# -----------------Auto Generation Step--------------------
source MUX_top.do
source ICAP_VIRTEX4_WRAPPER.do
source SimB_generator.do

OutFile_MUX_TOP $ReSim_Artifact_MUX_path $IO_type $IO_pin $IO_name $FileName $RM_num $RM_name
OutFile_SimB_TOP $ReSim_Artifact_SimB_path $RR_num $RM_num $RM_SimB_Len $MEM_ini_File_Name
OutFile_ICAP_VIRTEX4_WRAPPER_TOP $ReSim_Artifact_ICAP_VIRTEX4_WRAPPER_path $RM_hierachy_list $RM_num $RM_Defualt $RM_name
