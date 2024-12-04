use strict;
use warnings;

my $file = 'input.txt';
open my $info, $file or die "Could not open $file: $!";

{
    local $/ = undef;  # Temporarily undefine the input record separator
    my $file_content = <$info>;  # Slurp the entire file into a single string

    my $sum = 0;
    my $active = 1;
    while ($file_content =~ /(mul\((?<a1>\d+),(?<a2>\d+)\))|((?<cond>do|don't)\(\))/g) {
        if ($+{cond} eq 'do') {
            $active = 1;
        } elsif ($+{cond} eq "don't") {
            $active = 0;
        } elsif ($active) {
            $sum += $+{a1} * $+{a2};
        }
    }

    print "Part 2: $sum\n";
}

close $info;