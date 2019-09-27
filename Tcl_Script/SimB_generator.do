#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************
#----------------Random Number Generator -----------------
proc myRand { min max } {
    set maxFactor [expr [expr $max + 1] - $min]
    set value [expr int([expr rand() * 100])]
    set value [expr [expr $value % $maxFactor] + $min]
return $value
}
#--------------------Signiture--------------------
proc Signiture_Gen { Constant_list } {

    set max_N 15
    set min_N 0
    set Signature ""

    while {$Signature == "" || [lsearch -exact $Constant_list $Signature] != -1} {
        for {set i 0} {$i<8} {incr i} {
            set Signature_digi [format %X [myRand $min_N $max_N]]
            append Signature $Signature_digi
        }
    }
    return $Signature
}
#-----------------RR RM ID Generator----------------
proc RRRM_ID_gen {RR_N RM_N MNA} {
    set RR_RM_id_list {}
    set RRRM_list ""
    append RRRM_list [format "%02d" $RR_N]
    append RRRM_list [format "%02d" $RM_N]
    append RRRM_list 00
    append RRRM_list [format "%02d" $MNA]
    lappend RR_RM_id_list $RRRM_list
    lappend Constant_list $RRRM_list
    return $RR_RM_id_list
}

#----------------USER File outputer-----------------
proc file_ouputer {fp fp_MEM RR_num RM_num SimB_content_list Signature_list CONFIG_word_list RM_SimB_Len } {
    set SYNC        AA995566
    set Nop_v1      20000000
    set Wr_CRC_v1   30000001
    set Wr_FAR_v1   30002001
    set Wr_CMD_v1   30008001
    set WCFG        00000001
    set Wr_FDRI_v1  30004000
    set DESYNC      0000000D
    set MNA         2

    set Wr_Words_v2 500000
    append Wr_Words_v2 [format "%02x" [llength $CONFIG_word_list]]

    set Constant_list {}
    lappend Constant_list $SYNC
    lappend Constant_list $Nop_v1
    lappend Constant_list $Wr_CRC_v1
    lappend Constant_list $Wr_FAR_v1
    lappend Constant_list $Wr_CMD_v1
    lappend Constant_list $WCFG
    lappend Constant_list $Wr_FDRI_v1
    lappend Constant_list $Wr_Words_v2
    lappend Constant_list $DESYNC

    puts $fp "/**************************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia

This is ReSimPlus auto generated file, use for simulation only!

The purpose of this file is to Auto generate the SimB bitstream for simulation. The content of SimB
can be modify by the user.
**************************************************************************************************************/"
    set len 0
    foreach list_item $SimB_content_list {

        switch $list_item {
            "SYNC" {
                puts $fp "$SYNC // SYNC"
                puts $fp_MEM $SYNC
                incr len
            }

            "Nop_v1" {
                puts $fp "$Nop_v1 // Type 1 Nop"
                puts $fp_MEM $Nop_v1
                incr len
            }

            "Wr_CRC_v1" {
                puts $fp "$Wr_CRC_v1 // Type 1 Wr CRC (Cyclic Redundancy Check)"
                puts $fp_MEM $Wr_CRC_v1
                incr len
            }

            "Signature" {
                set Signiture 00000000
                set flag 0
                while { $flag ==0 || [lsearch -exact $Signature_list $Signiture] != -1} {
                    set Signiture [Signiture_Gen $Constant_list]
                    incr flag
                }
                puts $fp "$Signiture // Signature"
                puts $fp_MEM $Signiture
                incr len
            }

            "Wr_FAR_v1" {
                puts $fp "$Wr_FAR_v1 // Type 1 Wr FAR (Frame Address Reg)"
                puts $fp_MEM $Wr_FAR_v1
                incr len
            }

            "RR_RM_id" {
                set id [RRRM_ID_gen $RR_num $RM_num $MNA]
                puts $fp "$id // RRid:0x[format "%02d" $RR_num], RMid:0x[format "%02d" $RM_num], MNA:0x00[format "%02d" $MNA]"
                puts $fp_MEM $id
                incr len
            }

            "Wr_CMD_v1" {
                puts $fp "$Wr_CMD_v1 // Type 1 Wr CMD (Command)"
                puts $fp_MEM $Wr_CMD_v1
                incr len
            }

            "WCFG" {
                puts $fp "$WCFG // WCFG (Write Configuration)"
                puts $fp_MEM $WCFG
                incr len
            }

            "Wr_FDRI_v1" {
                puts $fp "$Wr_FDRI_v1 // Type 1 Wr FDRI (Frame Data Input)"
                puts $fp_MEM $Wr_FDRI_v1
                incr len
            }

            "Wr_Words_v2" {
                set m 0
                puts $fp "$Wr_Words_v2 // Type 2 Wr 16 Words"
                puts $fp_MEM $Wr_Words_v2
                foreach index $CONFIG_word_list {
                    puts $fp "$index // CONFIG_WORD $m"
                    puts $fp_MEM $index
                    incr m
                    incr len
                }
                incr len
            }

            "DESYNC" {
                puts $fp "$DESYNC // DESYNC"
                puts $fp_MEM $DESYNC
                incr len
            }

            default {
                puts $fp "Invalid"
                puts $fp_MEM "Invalid"
                incr len
            }
        }
    }
    while { $len < $RM_SimB_Len } {
        puts $fp "FFFFFFFF // fill the gap"
        puts $fp_MEM "FFFFFFFF"
        incr len
    }
    return $Signiture
}

# ---------------------SimB Generator-----------------------
proc OutFile_SimB_TOP {filePath RR_num RM_num RM_SimB_Len MEM_ini_File_Name} {

#------------------User-Defined-------------------
#CMD  Command
#FLR  Frame Length Reg
#COR  Configuration Option Reg
#MASK Control Mask Reg
#CTL  Control
#FAR  Frame Address Reg
#FDRI Frame Data Input
#CRC Cyclic Redundancy Check
#FDRO Frame Data Output
#LOUT Daisy-chain Data Output (DOUT)
#WCFG Write configuration

    set SimB_content_list "SYNC"
    lappend SimB_content_list "Nop_v1"
    lappend SimB_content_list "Wr_CRC_v1"
    lappend SimB_content_list "Signature"
    lappend SimB_content_list "Wr_FAR_v1"
    lappend SimB_content_list "RR_RM_id"
    lappend SimB_content_list "Wr_CMD_v1"
    lappend SimB_content_list "WCFG"
    lappend SimB_content_list "Wr_FDRI_v1"
    lappend SimB_content_list "Wr_Words_v2"
    lappend SimB_content_list "Nop_v1"
    lappend SimB_content_list "Nop_v1"
    lappend SimB_content_list "Wr_CMD_v1"
    lappend SimB_content_list "DESYNC"
    lappend SimB_content_list "Nop_v1"
    lappend SimB_content_list "Nop_v1"


    set CONFIG_word_list {2EBC3C0C 00000000 00000000 00000000 3A60981B 00000000 00000000 00000000 44D0ECAB 00000000 00000000 00000000 E025B2A3 00000000 00000000 00000000}

 #-------------Output the bitstream--------------
    set Signature_list {}
    set path_MEM $filePath
    append path_MEM "/$MEM_ini_File_Name"
    set fp_MEM [open $path_MEM  w+]

    for {set i 0} {$i<$RR_num} {incr i} {
        for {set j 0} {$j<$RM_num} {incr j} {
            set RM_x_path $filePath
            append RM_x_path "/RR$i\_RM$j\_SimB.txt"
            set fp [open $RM_x_path w+]
            set Signature_list_tmp [file_ouputer $fp $fp_MEM $i $j $SimB_content_list $Signature_list $CONFIG_word_list $RM_SimB_Len ]
            set Signature_list [concat $Signature_list $Signature_list_tmp]
            close $fp
            puts $Signature_list
        }
    }

    # Skip to where last newline should be; use -2 on Windows (because of CRLF)
    chan seek $fp_MEM -2 end
    # Save the offset for later
    set offset [chan tell $fp_MEM]
    # Only truncate if we're really sure we've got a final newline
    if {[chan read $fp_MEM] eq "\n"} {
        # Do the truncation!
        chan truncate $fp_MEM $offset
    }
    close $fp_MEM
}
