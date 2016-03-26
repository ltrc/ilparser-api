package hin;
use Dir::Self;
use Data::Dumper;
use hin::chunker;
use hin::dependencyparse;
use hin::guessmorph;
use hin::indic_wx_converter;
use hin::morph;
use hin::pruning;
use hin::postagger;
use hin::tokenizer;
use List::Util qw(pairs);
use strict;
use warnings;
use common::parser;
use common::pickonemorph;
use common::computehead;
use common::computevibhakti;

my $langobj = new_parser common::parser("hin", __PACKAGE__);

my @dispatch_seq = (
    "tokenizer",
    "utf2wx",
    "morph",
    "postagger",
    "chunker",
    "pruning",
    "guessmorph",
    "pickonemorph",
    "computehead",
    "computevibhakti",
    "dependencyparse"
);

sub init {
    #Register daemons here
    $langobj->register_daemons(__DIR__ . "/hin/daemons.ini");

    #Run all daemons
    foreach my $daemon (keys %{$langobj->{daemons}}) {
        $langobj->run_daemon($daemon);
    }
}

sub parse {
    my $self = shift;
    my %args = @_;
    $args{"langobj"} = $langobj;
    my %final_result;
    foreach my $index (0 .. $#dispatch_seq) {
        my $module = $dispatch_seq[$index ++];
        my $identifier = "${module}-$index";
        $final_result{$identifier} = __PACKAGE__->can($module)->(%args);
        $args{'data'} = $final_result{$identifier};
    }
    return \%final_result;
}

1;
