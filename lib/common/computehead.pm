package common::computehead;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/computehead/API";
use lib __DIR__ . "/computehead/src";
use strict;
use warnings;
use Exporter qw(import);
use computehead ();

our @EXPORT = qw(computehead);

sub computehead {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    computehead::computehead(\$data);
    select(STDOUT);
    return $result;
}

1;
