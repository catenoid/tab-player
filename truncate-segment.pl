use warnings;
use strict;

# For integration with the chrome extension:
# A web user higlights a tab segment.
# The horizontal positions of their highlighted selection's ends indicates the beat boundaries of that tab, i.e. a shorter segment of the entire tab.
# The remainder of the tab must be truncated for appropriate fit into extract-notes.pl

my @selection = ();
while (my $row = <>) {
  chomp($row);
  push @selection, $row;
}

# Pick up the indicies of the first consecutive bunch of strings
my $first_string_index;
my $first_string_note;
my $last_string_index;
my $last_string_note;
FILTER: {
  for my $i (0 .. $#selection) {
    if ($selection[$i] =~ /^(E|A|D|G|B)/i) {
      $first_string_index = $i;
      $first_string_note = $1;
      for my $j ($i .. $#selection) {
        if ($selection[$j] =~ /^(E|A|D|G|B)/i) {
          $last_string_index = $j;
          $last_string_note = $1;
        }
      }
      last FILTER;
    }
  }
}

($first_string_index != $last_string_index) or die "Not enough context to align\n";

my %note2number = (
  "b" => 1,
  "g" => 2,
  "d" => 3,
  "a" => 4,
  "e" => 5, 
);

$first_string_note = lc $first_string_note;
$last_string_note = lc $last_string_note;
my $first_string_note_number = $note2number{$first_string_note};
my $last_string_note_number = $note2number{$last_string_note};

# E string aliasing
if ($first_string_note_number == $last_string_note_number) {
  $first_string_note_number = 0;
}

my $incomplete_row_above = ($first_string_index != 0 and ($selection[$first_string_index-1] =~ /^(-|\d)+/)); 
if ($incomplete_row_above) {
  $first_string_index--;
}

# Supports 3+ strings
# 1 string: Correctness uncertain
# 2 strings: Not enought context to align, unless bars (|) are processed somehow
my @strings = @selection[$first_string_index .. $last_string_index];

my $first_partial = length($strings[0]);
my $full = length($strings[1]);
my $last_partial = length($strings[$#strings]);
my $offset = $full - $first_partial;
my $truncated_length = $last_partial - $offset;
# Check begin cursor comes before end cursor; that $truncated_length is positive

$strings[0] = (substr $strings[0], 0, $truncated_length);
for my $i (1 .. ($#strings-1)) {
  $strings[$i] = (substr $strings[$i], $offset, $truncated_length);
}
$strings[$#strings] = (substr $strings[$#strings], -$truncated_length);

my $blank_string = '-' x $truncated_length;
while ($first_string_note_number > 1) {
  unshift @strings, $blank_string;
  $first_string_note_number--;
}
while ($last_string_note_number < 5) {
  push @strings, $blank_string;
  $last_string_note_number++;
}

for my $string (@strings) {
  print "$string\n";
}
