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
# If 1st is not high e, take the 0th line too
my $first_string_index;
my $last_string_index;
FILTER: {
  for my $i (0 .. $#selection) {
    if ($selection[$i] =~ /^(E|A|D|G|B)/i) {
      print "found first string ($1) is on line $i\n";
      $first_string_index = $i;
      for my $j ($i .. $#selection) {
        if ($selection[$j] !~ /^(E|A|D|G|B)/i) {
          print "found last string ($1) is on line $j\n";
          $last_string_index = $j;
          last FILTER;
        }
      }
    }
  }
}

# eg. start-missing \n complete \n complete \n end-missing
# substring of completes as bound by the length of start-missing and end-missing
# Add blank strings (i.e. ----------------) as needed
# Either:
#  - Remove reference to string name, and modify extract-notes.pl to treat the first line of input as high e, OR
#  - Prepend each line with the string name
