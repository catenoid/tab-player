use warnings;
use strict;

# Each stanza is composed of 6 rows representing the guitar strings
my $guitar_string_count = 6;
my $strings_seen = 0;
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
  $a->[2] <=> $b->[2];
}

my $beat_count = 0;

# Parse the tab
while (my $row = <$tab_fh>) {
  my $last_string;
  if ($row =~ /(?<string>E|B|G|D|A)\|/i) {
    while ($' =~ /((?<note>\d+)|-)/) {
      if ((my $note = $+{'note'})) {
        push @unsorted_notes, [$strings_seen, $note, $beat_count];
      }
      $beat_count += length($1);
    }
    $strings_seen++;

    $last_string = ($strings_seen == $guitar_string_count);
    if ($last_string) {
      $strings_seen = 0;
    }
  }
}

@sorted_notes = sort ordered_note @unsorted_notes;

# Store in CSV
for my $i ( 0 .. $#sorted_notes ) {
  print $notes_fh "$sorted_notes[$i][0]";
  for my $j (1 .. $#{ $sorted_notes[$i] }) {
    print $notes_fh ",$sorted_notes[$i][$j]";
  }
  print $notes_fh "\n";
}
