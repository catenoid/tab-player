use warnings;
use strict;
use MIDI;

# MIDI numbers corresponding to the fundamental frequencies of a 6 string guitar standard tuning
my @string2MIDInumber = (64,59,55,50,45,40);

# Read in notes
my $infile = 'notes.csv';
open(my $notes_fh, '<:encoding(UTF-8)', $infile)
  or die "Could not open file '$infile' $!";

my @events = (
  ['text_event', 0, 'Your hand in mine'],
  ['set_tempo', 0, 450_000]
);

while (my $row = <$notes_fh>) {
  chomp($row);
  my ($string, $fret, $beat) = split(',', $row);
  my $note = ($string2MIDInumber[$string] + $fret);
  push @events,
    ['note_on', 0, 1, $note, 127], 
    ['note_off', 70, 0, $note, 0],
  ;
}

my $result_track = MIDI::Track->new({ 'events' => \@events });
my $opus = MIDI::Opus->new(
  { 'format' => 0, 'ticks' => 96, 'tracks' => [ $result_track ] } );
$opus->write_to_file( 'your_hand_in_mine.mid' );
