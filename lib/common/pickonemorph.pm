package common::pickonemorph;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/pickonemorph/API";
use lib __DIR__ . "/pickonemorph/src";
use strict;
use warnings;
use Exporter qw(import);
use pickonemorph ();

our @EXPORT = qw(pickonemorph);

sub pickonemorph {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    pickonemorph::pickonemorph(\$data);
    select(STDOUT);
    return $result;
}

1;
