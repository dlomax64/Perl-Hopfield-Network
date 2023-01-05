use strict;
use warnings;
use List::Util qw(sum);
use Text::CSV qw(csv);
use GD::Graph::lines;
use Statistics::Basic qw(:all);

# this should only be called by run_mult
# as it will supply all the correct arguments
# to this script after the runs

# number of files to congregate
my $runs = $ARGV[1];

# P tells me how many rows there are in each file
my $P = $ARGV[2];

# filename of the runs
my $filename = $ARGV[3]; 

# filename for the congregate of the data produced.
my $congregation = $ARGV[4];

# grab all data
my %all_runs = ();
for my $i (00..$runs) {
  my $file = $filename . $i . '.csv';
  open(my $fin, '<', $file) or die $!;

  my $header = '';
  while(<$fin>) {
    if(/^P,/x) {
      $header = $_;
      last;
    }
  }

  my $csv = Text::CSV->new();
  $csv->parse($header);
  $csv->column_names([$csv->fields]);

  my @pArr = ();
  my @imprints = ();
  my @probArr = ();
  my @unstableProbArr = ();
  while (my $row = $csv->getline_hr($fin)) {
    push(@{$all_runs{$file}{"Stable Imprints"}}, $row->{"Stable Imprints"});
    push(@{$all_runs{$file}{"Unstable Probability"}}, $row->{"Unstable Probability"});
  }
  close $fin;
  unlink($file);
  unlink($filename . $i . ".imprints.png");
  unlink($filename . $i . ".unstable.png");
}

# congregate into one csv file
my $file = $congregation . '.csv';
open(my $output, '>', $file) or die $!;
my @headers = ("P");

# headers for stable imprints
for(00..$runs) {
  push(@headers, ("Run $_ Stable Imprints"));
}
push(@headers, (
  "Stable Imprints Average", 
  "Stable Imprints STD", 
  "Stable Imprints STDERR",
  "Stable Imprints Upper",
  "Stable Imprints Lower",
));

# headers for unstable imprints
for(00..$runs) {
  push(@headers, ("Run $_ Unstable Probability"));
}
push(@headers, (
  "Unstable Fraction Average", 
  "Ustable Fraction STD",
  "Unstable Fraction STDERR",
  "Unstable Fraction Upper",
  "Unstable Fraction Lower"
  ));
my $csv = Text::CSV->new({sep_char => ','});
$csv->print($output, \@headers);
print $output "\n";

# fill data
for my $i (00..$P-1) {
  my @row = ();
  push(@row, $i);

  # data for stable imprints
  my @stableSeries = ();
  for(00..$runs) {
    push(@stableSeries, $all_runs{$filename . $_ . ".csv"}{"Stable Imprints"}[$i]);
  }
  my $stableAverage = sum(@stableSeries)/($runs + 1);
  my $stableStd = stddev(@stableSeries);
  my $stableStdErr = $stableStd/sqrt($runs+1);
  my $stableUpperBound = $stableAverage + $stableStdErr;
  my $stableLowerBound = $stableAverage - $stableStdErr;

  push(@row, @stableSeries);
  push(@row, ($stableAverage, $stableStd, $stableStdErr, $stableUpperBound, $stableLowerBound));

  # data for unstable fraction
  my @unstableSeries = ();
  for(00..$runs) {
    push(@unstableSeries, $all_runs{$filename . $_ . ".csv"}{"Unstable Probability"}[$i]);
  }
  my $unstableAverage = sum(@unstableSeries)/($runs + 1);
  my $unstableStd = stddev(@unstableSeries);
  my $unstableStdErr = $unstableStd/sqrt($runs+1);
  my $unstableUpperBound = $unstableAverage + $unstableStdErr;
  my $unstableLowerBound = $unstableAverage - $unstableStdErr;

  push(@row, @unstableSeries);
  push(@row, ($unstableAverage, $unstableStd, $unstableStdErr, $unstableUpperBound, $unstableLowerBound));

  $csv->print($output, \@row);
  print $output "\n";
}
close $output;

my @x_axis = (00..$P-1);
my @legend = ();
my @imprintData = ([@x_axis]);
my @unstableData = ([@x_axis]);

# grabbing data for graphs
for(00..$runs) {
  push(@imprintData, [@{$all_runs{$filename . $_ . ".csv"}{"Stable Imprints"}}]);
  push(@unstableData, [@{$all_runs{$filename . $_ . ".csv"}{"Unstable Probability"}}]);
  push(@legend, $filename . " " . $_);
}

# setup for stable graph
my $imprintGraph = GD::Graph::lines->new(1600, 900);
$imprintGraph->set(
  x_label => "Number of Imprints",
  y_label => "Number of Stable Imprints",
  title   => "Stable Imprints",
  y_max_value => 40
) or die $imprintGraph->error;
$imprintGraph->set_legend(@legend);

# setup for unstable graph
my $unstableGraph = GD::Graph::lines->new(1600, 900);
$unstableGraph->set(
  x_label => "Number of Imprints",
  y_label => "Fraction of Unstable Imprints",
  title   => "Fraction of Unstable Imprints",
  y_max_value => 1
) or die $unstableGraph->error;
$unstableGraph->set_legend(@legend);


# create imprints graph
my $igd = $imprintGraph->plot(\@imprintData) or die $imprintGraph->error;
my $iGraphName = $congregation . '.imprints.png';
open(IMG, '>', $iGraphName) or die $!;
binmode IMG;
print IMG $igd->png;
close IMG;

# create unstable graph
my $ugd = $unstableGraph->plot(\@unstableData) or die $unstableGraph->error;
my $uGraphName = $congregation . '.unstable.png';
open(IMG, '>', $uGraphName) or die $!;
binmode IMG;
print IMG $ugd->png;
close IMG;