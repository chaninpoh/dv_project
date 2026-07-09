#!/usr/bin/perl
use strict;
use warnings;
use File::Find;

# Customize your header here
my @header_lines = (
    "// ===============================================",
    "// Project      : SDRAM_LED_CONTROLLER",
    "// Description  : UVM CAPSTONE PROJECT",
    "// Author       : Su Lin Poh",
    "// Date         : " . localtime(),
    "// ===============================================",
    ""
);

# Directory containing .sv files
my $target_dir = shift || '.';

# Process each .sv file
find(sub {
    return unless /\.sv$/;
    my $file = $File::Find::name;

    # Read original content
    open my $in, '<', $file or die "Can't read $file: $!";
    my @content = <$in>;
    close $in;

    # Check if header already exists
    if ($content[0] =~ /^\/\/\s*Project/) {
        print "Skipping (header exists): $file\n";
        return;
    }

    # Write new content with header
    open my $out, '>', $file or die "Can't write $file: $!";
    print $out join("\n", @header_lines), "\n";
    print $out @content;
    close $out;

    print "Header added: $file\n";
}, $target_dir);
