#!/usr/bin/env tclsh
# vim:ft=tcl:foldmethod=marker

# Generates the Tcl documentation and tags file.

# Global Variables: {{{1

# }}}1

# Function: print_usage -- Print the usage text. {{{1
#
# Arguments:
#   args        Optional comment(s) to display first.
#
# Result:
#   None
#
# Side effect:
#   The usage text is printed and the program exits.
proc print_usage {args} {
    global argv0

    if {[llength $args] != 0} {
        puts [join $args "\n"]
        puts ""
    }

    puts "Usage: [file tail $argv0] \[Options\] <Directory>"
    puts ""
    puts "Generate the Tcl documentation for TagmaTags."
    puts "Reads the manual files in the specified directory."
    puts ""
    puts "Options:"
    puts "    -h            Display this text."
    puts "    -v            Verbose. List each document as it is generated."
    puts ""
    exit 1
}
# }}}1

# Function: process_opts -- Process the command line optons. {{{1
#
# Arguments:
#   None
#
# Result:
#   None
#
# Side effect:
#   Sets global variables where appropriate.
#   Prints the usage text when requested.
proc process_opts {} {
}
# }}}1

# Main Processing: {{{1

# Make sure the provided directory exists.
# file isdirectory $dir_name

print_usage

# Process the manual files.
foreach source_file [glob "*.n"] {
    puts $source_file
}
