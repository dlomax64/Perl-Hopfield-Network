use strict;
use warnings;

# set # of runs. These are going to be
# run in the background, so I limited them to 10 runs
# If no value is give, 5 is default
my $runs = $ARGV[1] || 5;
if($runs > 10) {
  die "Cannot do more than 10 runs\n";
}
$runs--; # 0 indexed

# set N. Default is 100
my $N = $ARGV[2] || 100;

# set P. Default is 50
my $P = $ARGV[3] || 50;

# set filename. Default is 'run'
my $filename = $ARGV[4] || 'run'; 

# filename for the congregate of the data produced.
# if not given it will not congregate the data.
my $congregation = $ARGV[5] || 0;

# performs runs
for(00..$runs) {
  my $file = $filename . $_;
  print "Running $_/$runs\n";
  `perl hopfield.pl -a $N $P $file`;
}

# if congregation was specifed, calls congregation
if($congregation) {
  `perl congregate.pl -a $runs $P $filename $congregation`;
}

print "DONE!\n";