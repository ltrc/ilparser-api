package hin::indic_wx_converter;
use Data::Dumper;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(utf2wx wx2utf);

sub utf2wx {
    my %args = @_;
    utf8::encode($args{data});
    my $result = $args{"langobj"}->call_daemon("utf2wx", $args{data});
    utf8::decode($result);
    return $result;
}

sub wx2utf {
    my %args = @_;
    utf8::encode($args{data});
    my $result = $args{"langobj"}->call_daemon("wx2utf", $args{data});
    utf8::decode($result);
    return $result;
}

1;
