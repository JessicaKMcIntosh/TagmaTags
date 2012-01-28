#!/usr/bin/perl -w
# vim:ft=perl:foldmethod=marker

use warnings;
use strict;

# Generates the Perl documentation and tags file.

# Hash for the tags.
# Keys are the tag names. Values are an array reference containing the file
# name and the search pattern.
my %tags = ();

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

# Generate the tags for perlfunc.man.
&gen_perlfunc;

# Generate the tags for posix.man.
# NOTE: Process this last since POSIX repeats functions.
&gen_section ('POSIX', 'posix.man', 'FUNCTIONS');

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

            # Skip if already exists in the tags hash.
            next if exists ($tags{$name});

            # Store it in the tags hash.
            $tags{$name} = [$file, '/^' . $line . '$'];
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
    my ($funcs, $last) = (0, '');
    while (defined (my $line = <$pdh>)) {
        # Write the line to perlfunc.man.
        print $manh $line;

        # See if the functions section has been found.
        chomp ($line);
        if (($last eq '-X') and ($line =~ m/^\s{16}-(\w)\s/)) {
            # Found a -X function.
            my $func = $1;

            # Store it in the tags hash with and without the leading -.
            $tags{$func} = ['perlfunc.man', '/^' . $line . '$'];
            $tags{'-' . $func} = ['perlfunc.man', '/^' . $line . '$'];
        } elsif ($funcs and ($line =~ m/^\s{4}(\w+)/)) {
            # Found a function.
            my $func = $1;

            # Skip if this was already processed.
            next if $func eq $last;

            # Store it in the tags hash.
            $tags{$func} = ['perlfunc.man', '/^' . $line . '$'];

            # Note that this function was seen.
            $last = $func;
        } elsif ($line =~ m/^\s{4}-X/) {
            # Found the functions section.
            $funcs = 1;
            $last = '-X';
        }
    }

    # Close filehandles.
    close ($pdh);
    close ($manh);
} # }}}1
