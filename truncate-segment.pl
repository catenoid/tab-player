use warnings;
use strict;

# For integration with the chrome extension:
# A web user higlights a tab segment.
# The horizontal positions of their highlighted selection's ends indicates the beat boundaries of that tab, i.e. a shorter segment of the entire tab.
# The remainder of the tab must be truncated for appropriate fit into extract-notes.pl

# Read in tab segment
my $infile = 'tab-segment.txt';
open(my $tab_fh, '<:encoding(UTF-8)', $infile)
  or die "Could not open file '$infile' $!";

# Store truncated tab for note extraction
my $outfile = 'tab-after-truncating.txt';
open(my $tr_tab_fh, '>', $outfile)
  or die "Could not open file '$outfile' $!";

my @selection = ();
while (my $row = <$tab_fh>) {
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
      print "found first string ($1) is on line $i: $selection[$i]\n";
      $first_string_index = $i;
      $first_string_note = $1;
      for my $j ($i .. $#selection) {
        if ($selection[$j] =~ /^(E|A|D|G|B)/i) {
          print "found last (?) string ($1) is on line $j\n";
          $last_string_index = $j;
          $last_string_note = $1;
        }
      }
      last FILTER;
    }
  }
}

my %note2number = (
  "e" => 0, 
  "b" => 1,
  "g" => 2,
  "d" => 3,
  "a" => 4,
);

$first_string_note = lc $first_string_note;
$last_string_note = lc $last_string_note;
my $first_string_note_number = $note2number{$first_string_note};
my $last_string_note_number = $note2number{$last_string_note};

# E string aliasing; Exception 1
if (($first_string_note_number != $last_string_note_number) and ($last_string_note eq 'e')) {
  $last_string_note_number = 5;
}

my $incomplete_row_above = ($first_string_index != 0 and ($selection[$first_string_index-1] =~ /^(-|\d)+/)); 
if ($incomplete_row_above) {
  print "Incomplete row above to add to the truncated tab\n";
  $first_string_index--;

  # E string aliasing; Exception 2
  if ($last_string_note eq 'e') {
    $last_string_note_number = 5;
  }
}
print "The first string note is $first_string_note_number\n";
print "The last sting note is $last_string_note_number\n";

# Supports 3+ strings
# 1 string: Correctness uncertain
# 2 strings: Not enought context to align, unless bars (|) are processed somehow
my @strings = @selection[$first_string_index .. $last_string_index];

my $first_partial = length($strings[0]);
print "First partial length is $first_partial\n";

my $full = length($strings[1]);
print "Full length is $full\n";

my $last_partial = length($strings[$#strings]);
print "Last partial length is $last_partial\n";

my $offset = $full - $first_partial;
print "Offset: $offset\n";

my $truncated_length = $last_partial - $offset;
# Check begin cursor comes before end cursor; that $truncated_length is positive
print "Truncated length: $truncated_length";

sub say {print @_, "\n"}

say "\nUntruncated strings:";
for my $string (@strings) {
  say $string;
}

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
  print $tr_tab_fh "$string\n";
}
