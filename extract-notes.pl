use warnings;
use strict;

# Each stanza is composed of 6 rows representing the guitar strings
my $guitar_string_count = 6;
my $strings_seen = 0;
my $stanza = 0;
my @unsorted_notes = ();
my @sorted_notes;

# Read in tabs
my $infile = 'tab.txt';
open(my $tab_fh, '<:encoding(UTF-8)', $infile)
  or die "Could not open file '$infile' $!";

# Store ordered notes for MIDI event conversion
my $outfile = 'notes.csv';
open(my $notes_fh, '>', $outfile)
  or die "Could not open file '$outfile' $!";
 
sub ordered_note {
  # Sorting function returns -1 when $a precedes $b in the result
  # $a and $b are array references
  # Binary <=> returns -1 if left < right, 0 if equal, 1 otherwise
  if ($a->[0] == $b->[0]) {
    # Notes are in the same stanza
    $a->[3] <=> $b->[3];
  } else {
  $a->[0] <=> $b->[0];
  }
}

# Parse the tab
while (my $row = <$tab_fh>) {
  my $last_string;
  if ($row =~ /(?<string>E|B|G|D|A)\|/i) {
    my $beat_count = 0;
    my $string = $+{'string'};
    while ($' =~ /((?<note>\d+)|-)/) {
      if ((my $note = $+{'note'})) {
        push @unsorted_notes, [$stanza,$string,$note,$beat_count];
      }
      $beat_count += length($1);
    }
    $strings_seen++;

    $last_string = ($strings_seen == $guitar_string_count);
    if ($last_string) {
      $stanza++;
      $strings_seen = 0;
    }
  }
}

@sorted_notes = sort ordered_note @unsorted_notes;

# Testing output
my $i;
for $i ( 0 .. $#sorted_notes ) {
   print "stanza $sorted_notes[$i][0], beat $sorted_notes[$i][3]\n";
}
