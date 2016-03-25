package hin::tokenizer;
use Data::Dumper;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(tokenizer);

sub tokenizer {
    my %args = @_;
    utf8::encode($args{data});
    my $sentences = $args{"langobj"}->call_daemon("tokenizer", $args{data});
    open INFILE, '<', \$sentences or die $!;
    my $result = "";
    my $ctr = 0;
    while (my $line = <INFILE>) {
        $ctr ++;
        $result .= "<Sentence id=\"$ctr\">\n";
        my @words = split ' ', $line;
        foreach my $index (0..$#words) {
            $result .= $index + 1 . "\t$words[$index]\tunk\n";
        }
        $result .= "</Sentence>";
    }
    close INFILE;
    utf8::decode($result);
    return $result;
}

1;
