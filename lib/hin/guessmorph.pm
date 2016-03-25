package hin::guessmorph;
use Data::Dumper;
use Dir::Self;
use lib __DIR__ . "/guessmorph/API";
use lib __DIR__ . "/guessmorph/src";
use strict;
use warnings;
use Exporter qw(import);
use guessmorph ();

our @EXPORT = qw(guessmorph);

sub guessmorph {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open OUTFILE, '>', \$result  or die $!;
    select(OUTFILE);
    guessmorph::guessmorph(\$data);
    select(STDOUT);
    return $result;
}

1;
