#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************
# ----------------Signal auto-assignment ------------------
proc assign_signals {fp RM_index IO_type_list IO_name_list IO_pin_list RM_num} {
    for { set i 0}  {$i < [llength $IO_type_list] } {incr i} {
        set signal_name [lindex $IO_name_list $i]
        set signal_pin [lindex $IO_pin_list $i]
        if {[lindex $IO_type_list $i] == "input"} {
            puts $fp "            RM$RM_index\_$signal_name = $signal_name\;"
            for {set j 0}  {$j < $RM_num } {incr j} {
                if {$j != $RM_index} {
                    puts $fp "            RM$j\_$signal_name = [expr $signal_pin+1]\'bx;"
                }
            }

        } else {
            puts $fp "            $signal_name = RM$RM_index\_$signal_name;"
        }

    }
}

proc assign_signals_default {fp RM_index IO_type_list IO_name_list IO_pin_list RM_num} {
    for { set i 0}  {$i < [llength $IO_type_list] } {incr i} {
        set signal_name [lindex $IO_name_list $i]
        set signal_pin [lindex $IO_pin_list $i]
        if {[lindex $IO_type_list $i] == "input"} {
            for {set j 0}  {$j < $RM_num } {incr j} {
                puts $fp "            RM$j\_$signal_name = [expr $signal_pin+1]\'bx;"
            }
        } else {
            puts $fp "            $signal_name <= 4'bx;"
        }

    }
}
# ----------------Setup the file write --------------------
proc OutFile_MUX_TOP {filePath IO_type_list IO_pin_list IO_name_list File_name RM_num RM_name} {

    set fp [open $filePath w+]
    puts $fp "/****************************************************************************************************
Author    : Zihao Cheng z5108506
Degree 	  : Bachelor of computer engineering
Supovisor : LinKan (George) Gong
Company	  : UNSW Sydney Australia

This is ReSimPlus auto generated file, use for simulation only!

The purpose of this file is to instantiate all RMs included in the RR region and connect each of them
by the virtual MUXs. Therefore, it allows ReSimPlus can select one of the RM in each RR to be
actived depended on the ICAPI bitstream traffic (When the condiction of re-configuration is
triggered, bitstream contain selected RM ID infomation will be updated through this ICAPI port).
****************************************************************************************************/"
    puts $fp "\n`timescale 1ns/1ps\n"
    puts $fp "//---------------------------------------------
//           Instantiating I/O port
//---------------------------------------------"

    puts $fp "module $File_name "
    puts $fp "("
    for { set i 0}  {$i < [llength $IO_type_list] } {incr i} {

       set IOtype [lindex $IO_type_list $i]
       puts -nonewline $fp "   $IOtype "
       if {$IOtype == "output"} {
           puts -nonewline $fp "reg"
       } else {
	   puts -nonewline $fp " "
       }

       if { [lindex $IO_pin_list $i] > 0 } {
	   set pin [lindex $IO_pin_list  $i]
	   puts -nonewline $fp " \[$pin\:0\]"

       }
       puts -nonewline $fp " [lindex $IO_name_list $i]"
       if { $i!= [expr [llength $IO_type_list]-1] } {
	   puts $fp ","
       } else {
           puts $fp ""
       }
    }
       puts $fp ");"

    puts $fp "\n//---------------------------------------------
//   Instantiating reconfigurable MUX-Logic
//---------------------------------------------\n"

    for { set j 0}  {$j < $RM_num } {incr j} {
       puts $fp "    //RM$j Interface"
       puts $fp "    reg       RM$j\_active;"

        for { set i 0}  {$i < [llength $IO_type_list] } {incr i} {
            if {[lindex $IO_type_list $i] == {output}} {
                puts -nonewline $fp "    wire"
            } else {
                puts -nonewline $fp "    reg"
            }
             if { [lindex $IO_pin_list $i] > 0 } {
        	 set pin [lindex $IO_pin_list  $i]
        	 puts -nonewline $fp " \[$pin\:0\]"
             } else {
		 puts -nonewline $fp "      "

             }
        	puts $fp " RM$j\_[lindex $IO_name_list $i];"
         }
        puts $fp ""

    }

    puts $fp "\n//---------------------------------------------
// Instantiating MUX connecting all RMs in RR
//---------------------------------------------\n"
    for { set j 0}  {$j <$RM_num } {incr j} {

        if {$j == 0} {
    	    puts $fp "    always@(*) begin"
    	    puts $fp "        if (RM0\_active) begin"

        }
	assign_signals $fp $j $IO_type_list $IO_name_list $IO_pin_list $RM_num
	if { $j!= [expr $RM_num - 1]} {puts $fp "        end else if (RM[expr $j+1]\_active)begin"}
    }
    puts $fp "        end else begin"
    assign_signals_default $fp $j $IO_type_list $IO_name_list $IO_pin_list $RM_num
    puts $fp "        end"
    puts $fp "    end"

   puts $fp "\n//---------------------------------------------
//        Instantiating all RMs in RR
//---------------------------------------------"
    for { set i 0}  {$i < [llength $RM_name] } {incr i} {
	puts $fp "    [lindex $RM_name $i] RM$i ("

	for {set j 0} {$j < [llength $IO_name_list]} {incr j} {
	    puts -nonewline $fp "        .[lindex $IO_name_list $j]   ( RM$i\_[lindex $IO_name_list $j] )"
	    if {$j != [expr [llength $IO_name_list]-1]} {
                puts $fp ","
	    } else {
		puts $fp ""
	    }
        }

	puts $fp "    );"


    }

    puts $fp "endmodule"
    close $fp

}
