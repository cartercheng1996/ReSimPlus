

set ReSim_Artifact_SimB_path "C:/Users/chine/Desktop/ReSimPlus/Tcl_Script/SimB"
set MEM_ini_File_Name "mem_bank.txt"
set RR_MUX_name_list {count arith op}
set RM_SimB_Len_List {32 64 128}
set RM_name_list { {count_up count_down} {arith_adder arith_subtractor} {op_sum op_difference op_comparer}}

source SimB_generator.do
set RR_num  [llength $RR_MUX_name_list]
OutFile_SimB_TOP $ReSim_Artifact_SimB_path $RR_num $RM_name_list $RM_SimB_Len_List $MEM_ini_File_Name
