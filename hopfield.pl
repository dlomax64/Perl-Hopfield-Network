use strict;
use warnings;
use List::Util qw(max);
use Text::CSV qw(csv);
use Data::Dumper qw(Dumper);
use GD::Graph::lines;

# cmd line args
my $N = $ARGV[1];
my $p = $ARGV[2];
my $file = $ARGV[3] || 'run_data';
my $graphName = $ARGV[4] || 'graph';

# setup output csv
my $filename = $file . '.csv';
open ( my $output, '>', $filename ) or die $!;
my @headers = ("P", "Stable Imprints", "Stable Probability", "Unstable Probability");
my $csv = Text::CSV->new({sep_char => ','});
$csv->print($output, \@headers);
print $output "\n";

# arrays for bipolar vec and weights
my @array = ();
my @weights = ();

# sub 1 to make loops 0 indexed, set defaults if no args
$N = ($N) ? $N - 1 : 99;
$p = ($p) ? $p - 1 : 49;

# initialize bipolar arrays
for my $x (00..$p) {
  $array[$x] = [ getArray($N) ];
}
# initialize NXN W with 0's
for my $x (00..$N) {
  $weights[$x] = [ getArray($N, $x) ];
}

# imprint patterns
my $array_ref = \@array;
my $weights_ref = \@weights;
my @stableImprints = (0) x ($p + 1);
my @unstableFrac = (0) x ($p + 1);
for my $x (00..$p) {
  my @stabilityArr = (0) x ($p + 1);
  my @probArr = (0) x ($p + 1);
  my @unstableProbArr = (0) x ($p + 1);
  my $count = 0;

  print "Imprinting on: $x/$p\n";
  imprintPatterns($array_ref, $weights_ref, $N, $x);

  # Test for stability
  for my $y (00..$x) {
    my @net = @{$array[$y]};
    my $unstable = 0;

    for my $i (00..$N) {
      my $h_i = 0;
      for my $j (00..$N) {
        my $product = $weights[$i][$j] * $net[$j];
        $h_i += $product;
      }
      $h_i = ($h_i >= 0) ? 1 : -1;
      if($net[$i] != $h_i) {
        $unstable = 1;
        last;
      }
    }
    unless($unstable) {
      $stabilityArr[$y] = 1;
      $count++;
    }

    # calculate probabilities of stable/unstable imprints
    $probArr[$y] = ($count) ? $count/($y + 1) : 0;
    $unstableProbArr[$y] = 1 - $probArr[$y];
  }
  $stableImprints[$x] = $count;
  $unstableFrac[$x] = $unstableProbArr[$x];

  my @row = ($x, $count, $probArr[$x], $unstableProbArr[$x]);
  $csv->print($output, \@row);
  print $output "\n";
}
close $output;

my @x_axis = (00..$p);

# setup for imprint graph
my @imprintData = ([@x_axis], [@stableImprints]);
my $imprintGraph = GD::Graph::lines->new(1600, 900);
$imprintGraph->set(
  x_label => "Number of Imprints",
  y_label => "Number of Stable Imprints",
  title   => "Stable Imprints",
  y_max_value => max(@stableImprints)
) or die $imprintGraph->error;

# setup for unstable graph
my @unstableData = ([@x_axis], [@unstableFrac]);
my $unstableGraph = GD::Graph::lines->new(1600, 900);
$unstableGraph->set(
  x_label => "Number of Imprints",
  y_label => "Fraction of Unstable Imprints",
  title   => "Fraction of Unstable Imprints",
  y_max_value => 1
) or die $unstableGraph->error;


# create imprints graph
my $igd = $imprintGraph->plot(\@imprintData) or die $imprintGraph->error;
my $iGraphName = $file . '.imprints.png';
open(IMG, '>', $iGraphName) or die $!;
binmode IMG;
print IMG $igd->png;
close IMG;

# create unstable graph
my $ugd = $unstableGraph->plot(\@unstableData) or die $unstableGraph->error;
my $uGraphName = $file . '.unstable.png';
open(IMG, '>', $uGraphName) or die $!;
binmode IMG;
print IMG $ugd->png;
close IMG;

# subroutine to imprint the patterns
sub imprintPatterns {
  my @array = @{$_[0]};
  my @W = @{$_[1]};
  my $N = $_[2];
  my $p = $_[3];

  for my $i (00..$N) {
    for my $j (00..$N) {
      next if($i == $j);
      my $sum = 0;
      for my $k (00..$p) {
        my $product = $array[$k][$i] * $array[$k][$j];
        $sum += $product;
      }
      $sum *= 1/($N + 1);
      $W[$i][$j] = $sum;
    }
  }
}

# helper subroutine to initialize arrays
sub getArray {
  my $N = $_[0];
  my $option = $_[1]; # flag to initialize array with 0's instead

  my @array = (0) x ($N + 1);
  unless($option) {
    for my $y (00..$N) {
      $array[$y] = (rand() >= .5) ? 1 : -1;
    }
  }
  return @array;
}