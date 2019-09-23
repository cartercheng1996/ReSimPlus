#This code aims aligning the print out content
#Reference: https://stackoverflow.com/questions/7384349/how-to-display-output-in-a-uniformed-manner-in-tcl

package require struct::matrix

proc aligning_print1 {lines} {
    struct::matrix m; # Create a new matrix
    m add columns 3; # The matrix has 3 columns: file name, date, and time
    foreach line $lines {
        m add row $line; # Add a line to the matrix
    }
    m format 2chan; # Prints it out	

}

proc aligning_print2 {lines} {
    foreach fields $lines {
	set column 0
	foreach field $fields {
	    set w [string length $field]
	    if {![info exist width($column)] || $width($column) < $w} {
		set width($column) $w
	    }
	    incr column
	}
    }
    foreach fields $lines {
	set column 0
	foreach field $fields {
	    puts -nonewline [format "%-*s " $width($column) $field]
	    incr column
	}
	puts ""; # Just the newline please
    }
}


