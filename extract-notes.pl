use warnings;
use strict;

# Read in tabs
my $infile = 'tab-after-truncating.txt';
open(my $tab_fh, '<:encoding(UTF-8)', $infile)
  or die "Could not open file '$infile' $!";

# Store ordered notes for MIDI event conversion
my $outfile = 'notes.csv';
open(my $notes_fh, '>', $outfile)
  or die "Could not open file '$outfile' $!";
 
# Parse the tab
# Each stanza is composed of 6 rows representing the guitar strings
my $guitar_string_count = 6;
my $string = 0;
my @unsorted_notes = ();
my @sorted_notes;
my $beat_offset = 0;
my $is_last_string;

sub ordered_note {
  # Sorting function returns -1 when $a precedes $b in the result
  # $a and $b are array references
  # Binary <=> returns -1 if left < right, 0 if equal, 1 otherwise
  $a->[2] <=> $b->[2];
}

while (my $row = <$tab_fh>) {
  my $beat;
  my $beat_mantissa = 0;
  while ($row =~ /((?<fret>1[0-5]|[0-9])|-+|.)/g) {
    # Tabs can concatenate single-digit notes; Stop at fret 15
    $beat = $beat_offset + $beat_mantissa;
    if (defined($+{'fret'})) {
      push @unsorted_notes, [$string, $+{'fret'}, $beat];
    }
    $beat_mantissa += length($1);
  }
  $string++;

  $is_last_string = ($string == $guitar_string_count);
  if ($is_last_string) {
    $string = 0;
    $beat_offset = $beat;
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
