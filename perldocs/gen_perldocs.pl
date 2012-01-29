#!/usr/bin/perl -w
# vim:ft=perl:foldmethod=marker

use warnings;
use strict;

# Generates the Perl documentation and tags file.

# Hash for the tags.
# Keys are the tag names. Values are an array reference containing the file
# name and the search pattern.
my %tags = ();

# Generate the tags for perlfunc.man.
# NOTE: Process this first so basic functions override all other tags.
&gen_perlfunc;

# Generate the tags for autosplt.man.
&gen_section ('AutoSplit', 'SYNOPSIS', qr/^\s+(\w+)/);

# Generate the tags for benchmark.man.
&gen_section ('Benchmark', 'DESCRIPTION', qr/^\s{4}(\w+)\s*\(/);

# Generate the tags for carp.man.
&gen_section ('Carp', 'NAME');

# Generate the tags for classstruct.man.
&gen_section ('Class::Struct', 'SYNOPSIS', qr/.*\s(struct)/);

# Generate the tags for cwd.man.
&gen_section ('Cwd', 'DESCRIPTION', qr/^\s{4}(\w*(?:cwd|path))$/);

# Generate the tags for datadumper.man.
&gen_section ('Data::Dumper', 'SYNOPSIS', qr/^\s{8}print\s+(Dumper)\(/);

# Generate the tags for error.man.
&gen_section ('Error', 'PROCEDURAL INTERFACE', qr/^\s{4}(\w+)\s+[[:upper:]]/);

# Generate the tags for filebasename.man.
&gen_section ('File::Basename', 'DESCRIPTION', qr/^\s{4}"(\w+)"/);

# Generate the tags for filecheckTree.man.
&gen_section ('File::CheckTree', 'SYNOPSIS', qr/.*\s(validate)/);

# Generate the tags for filecompare.man.
&gen_section ('File::Compare', 'DESCRIPTION', qr/^\s{4}\w*\s*\w+::\w+::(\w+)/);

# Generate the tags for filecopy.man.
&gen_section ('File::Copy', 'DESCRIPTION', qr/^\s{4}(\w+)(?:\([^)]+\))?$/);

# Generate the tags for filecopy.man.
&gen_section ('File::Find', 'SYNOPSIS', qr/^\s{8}(\w+)\(/);

# Generate the tags for filelisting.man.
&gen_section ('File::Listing', 'SYNOPSIS', qr/.*\s(parse_dir)/);

# Generate the tags for filecopy.man.
&gen_section ('File::Path', 'DESCRIPTION', qr/^\s{4}(\w+)\(/);

# Generate the tags for filetemp.man.
&gen_section ('File::Temp', 'FUNCTIONS', qr/^\s{4}(\w+)$/);

# Generate the tags for getoptlong.man.
&gen_section ('Getopt::Long', 'SYNOPSIS', qr/.*\s(GetOptions)\s/);

# Generate the tags for getoptstd.man.
&gen_section ('Getopt::Std', 'SYNOPSIS', qr/^\s{8}(\w+)\(/);

# Generate the tags for hashutil.man.
&gen_section ('Hash::Util', 'DESCRIPTION', qr/^\s{4}(\w+)$/);

# Generate the tags for listutil.man.
&gen_section ('List::Util', 'DESCRIPTION', qr/^\s{4}(\w+)\s+[[:upper:]]/);

# Generate the tags for scalarutil.man.
&gen_section ('Scalar::Util', 'DESCRIPTION', qr/^\s{4}(\w+)\s+[[:upper:]]/);

# Generate the tags for searchdict.man.
&gen_section ('Search::Dict', 'SYNOPSIS', qr/.*\s(look)/);

# Generate the tags for switch.man.
&gen_section ('Switch', 'SYNOPSIS', qr/^\s+(switch|case)/);

# Generate the tags for symbol.man.
&gen_section ('Symbol', 'DESCRIPTION', qr/^\s{4}"\w+::(\w+)"/);

# Generate the tags for test.man.
&gen_section ('Test', 'QUICK START GUIDE', qr/^\s{4}"(\w+)\(/);

# Generate the tags for testharness.man.
&gen_section ('Test::Harness', 'FUNCTIONS', qr/^\s+(\w+)\(/);

# Generate the tags for testmore.man.
&gen_section ('Test::More', 'DESCRIPTION', qr/^\s{4}(\w+)$/);

# Generate the tags for textabbrev.man.
&gen_section ('Text::Abbrev', 'SYNOPSIS', qr/\s*(abbrev)/);

# Generate the tags for textbalanced.man.
&gen_section ('Text::Balanced', 'DESCRIPTION', qr/^\s+"(\w+)"$/);

# Generate the tags for textcharwidth.man.
&gen_section ('Text::CharWidth', 'SYNOPSIS', qr/^\s+(\w+)\(/);

# Generate the tags for textparsewords.man.
&gen_section ('Text::ParseWords', 'SYNOPSIS', qr/\s(\w+)\(/);

# Generate the tags for textsoundex.man.
&gen_section ('Text::Soundex', 'SYNOPSIS', qr/\s(\w+)\(/);

# Generate the tags for texttabs.man.
&gen_section ('Text::Tabs', 'SYNOPSIS', qr/\s(\w+)\(/);

# Generate the tags for textwrap.man.
&gen_section ('Text::Wrap', 'DESCRIPTION', qr/^\s{4}"?\w+::\w+::(\w+)/);

# Generate the tags for timezone.man.
&gen_section ('Time::Zone', 'DESCRIPTION', qr/^\s{4}"(\w+)/);

# Generate the tags for perlvar.man.
# NOTE: This is processed late to give preference to function names over
# variable names.
&gen_perlvar;

# Generate the tags for pragmas.
# NOTE: These are processes late to give preference to other
# modules/functions/variables.
&gen_pragmas;

# Generate the tags for posix.man.
# NOTE: Process this last since POSIX repeats functions.
&gen_section ('POSIX', 'posix.man', 'FUNCTIONS');

# Write the tags file.
&write_tags;

# add_tag -- Add a tag to the %tags hash. {{{1
#
# Arguments:
#   $tag        The tag name to add.
#   $value      The value for the tag.
#
# Result:
#   None
#
# Side effect:
#   The tag is added to the %tags hash if it does not already exist.
sub add_tag {
    my ($tag, $value) = @_;

    # Make sure the tag does not already exist.
    return 0 if exists ($tags{$tag});

    # Add the tag to the %tags hash.
    $tags{$tag} = $value;

    return 1;
} # }}}1

# gen_section -- Generate the tags from a section of documentation. {{{1
#
# Arguments:
#   $doc        Documentation to generate from.
#   $section    The section in the documentation to generate tags for.
#   $re         Regexp to match against the line. Optional.
#               Must contain one capture returning the tag name.
#
# Result:
#   None
#
# Side effect:
#   Creates the manual file.
#   The manual file name is based on the documentation section.
#   Adds the tags to the %tags hash.
sub gen_section {
    # Arguments.
    my ($doc, $section, $re) = @_;
    $re = qr/^\s{4}(\w+)/ unless defined ($re);
    (my $file = lc ($doc) . '.man') =~ s/://g;

    # Read the documentation.
    open (my $pdh, '-|', 'perldoc -t -T ' . $doc) or
        die "Could not read from perldoc: $!\n";
    return 0 if $?;

    # Create the file.
    open (my $manh, '>', $file) or
        die "Could not create the $file file: $!\n";

    # Process the documentation.
    my ($found) = (0);
    while (defined (my $line = <$pdh>)) {
        # Write the line to the manual file.
        print $manh $line;

        # See if the section has been found.
        chomp ($line);
        if (($found == 1) and ($line =~ $re)) {
            # Found a tag item.
            my $name = $1;

            # Add the tag to the the %tags hash.
            &add_tag ($name, [$file, '/^' . $line . '$']);
        } elsif (($found == 1) and ($line =~ m/^[[:upper:]][[:upper:][:space:]]+$/)) {
            # End of the section.
            $found = -1;
        } elsif (($found == 0) and ($line eq $section)) {
            # Found the section.
            $found = 1;
        }
    }

    # Close filehandles.
    close ($pdh);
    close ($manh);

    return 1;
} # }}}1

# gen_perlfunc -- Generate the tags for perlfunc.man. {{{1
#
# Arguments:
#   None
#
# Result:
#   None
#
# Side effect:
#   Creates the perlfunc.man file.
#   Adds the tags to the %tags hash.
sub gen_perlfunc {
    # Read the perlfunc documentation.
    open (my $pdh, '-|', 'perldoc -t -T perlfunc') or
        die "Could not read from perldoc: $!\n";

    # Create the perlfunc.man file.
    open (my $manh, '>', 'perlfunc.man') or
        die "Could not create the perlfunc.man file: $!\n";

    # Process the documentation.
    my ($funcs, $prev) = (0, '');
    while (defined (my $line = <$pdh>)) {
        # Write the line to perlfunc.man.
        print $manh $line;

        # See if the functions section has been found.
        chomp ($line);
        if (($prev eq '-X') and ($line =~ m/^\s{16}-(\w)\s/)) {
            # Found a -X function.
            my $func = $1;

            # Add it to the %tags hash with and without the leading -.
            &add_tag ($func, ['perlfunc.man', '/^' . $line . '$']);
            &add_tag ('-' . $func, ['perlfunc.man', '/^' . $line . '$']);
        } elsif ($funcs and ($line =~ m/^\s{4}(\w+)/)) {
            # Found a function.
            my $func = $1;

            # Add the tag to the %tags hash.
            &add_tag ($func, ['perlfunc.man', '/^' . $line . '$']);

            # Note that this function was seen.
            $prev = $func;
        } elsif ($line =~ m/^\s{4}-X/) {
            # Found the functions section.
            $funcs = 1;
            $prev = '-X';
        }
    }

    # Close filehandles.
    close ($pdh);
    close ($manh);

    return 1;
} # }}}1

# gen_perlvar -- Generate the tags for perlvar.man. {{{1
#
# Arguments:
#   None
#
# Result:
#   None
#
# Side effect:
#   Creates the perlvar.man file.
#   Adds the tags to the %tags hash.
sub gen_perlvar {
    # Read the perlvar documentation.
    open (my $pdh, '-|', 'perldoc -t -T perlvar') or
        die "Could not read from perldoc: $!\n";

    # Create the perlvar.man file.
    open (my $manh, '>', 'perlvar.man') or
        die "Could not create the perlvar.man file: $!\n";

    # Process the documentation.
    while (defined (my $line = <$pdh>)) {
        # Write the line to perlvar.man.
        print $manh $line;

        chomp ($line);
        if ($line =~ m/^\s{4}([\$\@\%]\S+)/) {
            # Found a variable.
            my $var = $1;

            # Strip any trailing example brace.
            $var =~ s/\{[^}]+\}// unless $var =~ /^.\{/;

            # Add it to the %tags hash.
            &add_tag ($var, ['perlvar.man', '/^' . $line . '$']);

            # If the variable does not contain braces add it without the sigil.
            if ($var =~ /^[\$\@\%]([^{]+)$/) {
                &add_tag ($1, ['perlvar.man', '/^' . $line . '$']);
            }
        }
    }

    # Close filehandles.
    close ($pdh);
    close ($manh);

    return 1;
} # }}}1

# gen_pragmas -- Generate the tags for pragmas. {{{1
#
# Arguments:
#   None
#
# Result:
#   None
#
# Side effect:
#   Calls gen_pragma_doc to generate the documentation file and tags.
sub gen_pragmas {
    # Read the documentation for perlmodlib to get the list of pragmas.
    open (my $pdh, '-|', 'perldoc -t -T perlmodlib') or
        die "Could not read from perldoc: $!\n";
    return 0 if $?;

    # Read the perlmodlib documentation and gather a list of pragmas.
    my @pragmas = ();
    my $found = 0;
    while (defined (my $line = <$pdh>)) {
        if (($found == 0) and ($line =~ m/^\s{4}attributes\s/)) {
            # Found the Pragma list.
            $found = 1;
        }
        if (($found == 1) and ($line =~ m/^\s{4}(\w+)\s/)) {
            # Found a pragma.
            push (@pragmas, $1);
        }
        if (($found == 1) and ($line =~ m/^\s+Standard\s+Modules\s*$/)) {
            # End of the pragma list.
            last;
        }
    }
    close ($pdh);

    # Loop over the list of pragmas and generate the tags and documentation
    # files for each.
    for my $pragma (@pragmas) {
        &gen_pragma_doc ($pragma);
    }

    return 1;
} # }}}1

# gen_pragma_doc -- Generate the tags and documentation for a pragma. {{{1
#
# Arguments:
#   $pragma     The pragma to generate documentation for.
#
# Result:
#   None
#
# Side effect:
#   Creates the pragma manual file.
#   Adds tags for the pragmas to the %tags hash.
#   Tags are created with and without a leading 'use' and 'no' (where applicable).
sub gen_pragma_doc {
    # Arguments.
    my ($pragma) = @_;
    my $file = 'pragma' . lc ($pragma) . '.man';

    # Read the documentation.
    open (my $pdh, '-|', 'perldoc -t -T ' . $pragma) or
        die "Could not read from perldoc: $!\n";

    # Create the file.
    open (my $manh, '>', $file) or
        die "Could not create the $file file: $!\n";

    # Process the documentation.
    my ($section, $has_no, $tag_line, $pragma_re, $has_no_re) =
       ('', 0, '', qr/^\s+$pragma\s+-/, qr/^\s+no\s+$pragma/);
    while (defined (my $line = <$pdh>)) {
        # Write the line to the manual file.
        print $manh $line;

        # Look for the tag line and if the module as a 'no' usage.
        chomp ($line);
        if (($section eq 'NAME') and ($line =~ $pragma_re)) {
            # Found the tag line.
            $tag_line = $line;
        } elsif (($section eq 'SYNOPSIS') and ($line =~ $has_no_re)) {
            # The pragma has a 'no' usage.
            $has_no = 1;
        } elsif ($line =~ m/^[[:upper:]][[:upper:][:space:]]+$/) {
            # Found a section.
            $section = $line;
        }
    }

    # Close filehandles.
    close ($pdh);
    close ($manh);

    # Add the tags for the pragma.
    &add_tag ($pragma, [$file, '/^' . $tag_line . '$']);
    &add_tag ('use ' . $pragma, [$file, '/^' . $tag_line . '$']);
    &add_tag ('no ' . $pragma, [$file, '/^' . $tag_line . '$']) if $has_no;

    return 1;
} # }}}1

# write_tags -- Write the tags file from the %tags hash. {{{1
#
# Arguments:
#   None
#
# Result:
#   None
#
# Side effect:
#   The tags file is created.
sub write_tags {
    # Create the tags file.
    open (my $tagh, '>', 'tags') or die "Could not create the tags file $!\n";

    # Write the tags file header.
    print $tagh "!_TAG_FILE_SORTED\t2\t/0=unsorted, 1=sorted, 2=foldcase/\n";

    # Write the tags to the file.
    for my $tag (sort {uc($a) cmp uc($b)} keys (%tags)) {
        print $tagh join ("\t", $tag, @{$tags{$tag}}) . "\n";
    }

    # Close the tags file.
    close ($tagh);

    return 1;
} # }}}1
