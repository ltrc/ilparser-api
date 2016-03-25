package common::computevibhakti;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/computevibhakti/API";
use lib __DIR__ . "/computevibhakti/src";
use strict;
use warnings;
use Exporter qw(import);
use vibhakticompute;

our @EXPORT = qw(computevibhakti);

sub computevibhakti {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    vibhakticompute(\$data, 1);
    select(STDOUT);
    return $result;
}

1;
