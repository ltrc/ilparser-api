package hin::dependencyparse;
use Data::Dumper;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(dependencyparse);

sub dependencyparse {
    my %args = @_;
    utf8::encode($args{data});
    my $result = $args{"langobj"}->call_daemon("parser", $args{data});
    utf8::decode($result);
    return $result;
}

1;
