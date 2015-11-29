use warnings;
use strict;

my $tab = 'tab.txt';
open(my $fh, '<:encoding(UTF-8)', $tab)
  or die "Could not open file '$tab' $!";
 
while (my $row = <$fh>) {
  if ($row =~ /(?<string>e|B|G|D|A|E)\|/) {
    my $beat_count = 0;
    my $string = $+{'string'};
    while ($' =~ /((?<note>\d+)|-)/) {
      if ((my $note = $+{'note'})) {
        print "string: $string, note: $note, beat: $beat_count\n";
      }
      $beat_count += length($1);
    }
  }
}
