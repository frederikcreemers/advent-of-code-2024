use strict;
use warnings;

my $file = 'input.txt';
open my $info, $file or die "Could not open $file: $!";

{
    local $/ = undef;  # Temporarily undefine the input record separator
    my $file_content = <$info>;  # Slurp the entire file into a single string

    my $sum = 0;
    while ($file_content =~ /mul\((\d+),(\d+)\)/g) {
        $sum += $1 * $2;
    }

    print "Part 1: $sum\n";
}

close $info;