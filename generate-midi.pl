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

my $previous_beat = -1; # we don't want the first is_chord to test true
my @chord = (); # For collecting notes that are played simultaneously

while (my $row = <$notes_fh>) {
  chomp($row);
  my ($string, $fret, $beat) = split(',', $row);
  my $note = ($string2MIDInumber[$string] + $fret);

  my $is_chord = ($beat == $previous_beat);
  if ($is_chord) {
    push @chord, $note;
  } else {
    # Note ons
    for my $chord_note (@chord) {
      push @events,
        ['note_on', 0, 1, $chord_note, 127]; 
    }

    # Note offs -- Destroy array
    while (my $chord_note = shift(@chord)) {
      push @events,
        ['note_off', 110, 1, $chord_note, 127]; 
    }
    
    # Begin a new (potential) chord
    push @chord, $note;
  }
  $previous_beat = $beat;
}

my $result_track = MIDI::Track->new({ 'events' => \@events });
my $opus = MIDI::Opus->new(
  { 'format' => 0, 'ticks' => 96, 'tracks' => [ $result_track ] } );
$opus->write_to_file( 'your_hand_in_mine.mid' );
