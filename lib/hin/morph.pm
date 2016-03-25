package hin::morph;
use Data::Dumper;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(morph);

my @dispatch_seq = (
    "remove_sentence_tag",
    "remove_ssf",
    "normalizer",
    "spell_variation",
    "morph_analyser",
    "add_sentence_tag"
);

sub add_sentence_tag {
    my %par = @_;
    my $data = $par{'data'};
    open INFILE, '<', \$data  or die $!;
    my $result = "<Sentence id=\"1\">\n";
    while (my $line=<INFILE>) {
        $result .= $line;
    }
    $result .= "</Sentence>\n";
    return $result;
}

sub morph {
    my %args = @_;
    utf8::encode($args{"data"});
    foreach my $submodule (@dispatch_seq) {
        $args{'data'} = __PACKAGE__->can($submodule)->(%args);
    }
    utf8::decode($args{"data"});
    return $args{"data"};
}

sub morph_analyser {
    my %args = @_;
    return $args{"langobj"}->call_daemon("morph", $args{data});
}

sub normalizer {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    foreach my $line (split /(?<=\n)/, $data) {
        utf8::decode($line);

        $line =~ s/\x{2018}/'/g; # <2018> ‘ is Replaced by single quote "'"
        $line=~s/\x{2019}/'/g; # <2019> ’ is Replaced by single quote "'"
        $line=~s/\x{201C}/"/g; # <201C> “ is Replaced by single quote "
        $line=~s/\x{201D}/"/g; # <201D> ” is Replaced by single quote "

        $line=~s/\x{200D}//g; # <200D> is Removed
        $line=~s/\x{200C}//g; # <200C> is Removed
        $line=~s/\x{feff}//g; # <feff> is Removed
        $line=~s/\x{0D}//g; # ^M is Removed

        utf8::encode($line);
        $result .= $line;
    }
    return $result;
}

sub remove_sentence_tag {
    my %par = @_;
    my $data = $par{'data'};
    open INFILE, '<', \$data or die $!;
    my $result = "";
    while(my $line=<INFILE>) {
        if($line=~/^</) {
            next;
        } else {
            $result .= $line;
        }
    }
    return $result;
}

sub remove_ssf {
    my %par = @_;
    my $data = $par{'data'};
    open INFILE, '<', \$data  or die $!;
    my $result = "";
    my $_prev = 1;
    while (my $line=<INFILE>) {
        if ($line=~m/^0\t/) {
            $_prev=2;
            next;
        } elsif ($line=~/^\t\)\)/ and $_prev=~/^\t\)\)/) {
            $_prev="\t))";
            next;
        } else {
            $_prev="$line";
            $result .= "$line";
        }
    }
    return $result;
}

sub spell_variation {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    foreach my $line (split /(?<=\n)/, $data) {
        chomp($line);
        my ($word1, $word);
        $line=~/([0-9]*)\t(.*)/;
        my $num=$1;
        $word=$2;
        $word1 = "";

        if($word=~/Zaè/) {
            $word=~s/Zaè/Z/g;
        }

        if($word=~/nx/) {
            $word=~s/([A-z]*)nx([A-z]*)/$1Mx$2/g;
        }

        if($word=~/nisahAya/) {
            $word=~s/nisahAya/nissahAya/g;
        }

        if($word=~/muJa/) {
            $word=~s/muJa/mere/g;
        }

        #if($word=~/OY/) {
        #        $word=~s/OY/A/g;
        #        }
        #if($word1 ne "") {
        #print "1\t$word1\n";
        #}
        if($word=~/dZ/) {
            $word=~s/dZ/d/g;
        }

        if($word=~/DZ/) {
            $word=~s/DZ/D/g;
        }

        if($word=~/AMKe/) {
            $word=~s/AMKe/AzKe/g;
        }
        if($word=~/([A-z]+)\.\./) {
            $word=~/([A-z]+)\.(.*)\.\t/;
            $word=$1."\tunk";
            $word1="\.".$2."\.";
        }
        if($word=~/([A-z]+)(\.\.\.)+/) {
            $word=~s/([A-z]+)(\.\.\.)/$1 $2/g;
        }
        if($word=~/([0-9]+)veM/) {
            $word=~/([0-9]+)veM/g;
            $word=$1."\tunk";
            $word1="veM";
        }
        if($word=~/([0-9]+)vIM/) {
            $word=~/([0-9]+)vIM/g;
            $word=$1."\tunk";
            $word1="vIM";
        }
        if($word=~/([0-9]+)vAM/) {
            $word=~/([0-9]+)vAM/g;
            $word=$1."\tunk";
            $word1="vAM";
        }
        if($word=~/([A-z]+ne)vAlA/) {
#        $word=~s/([A-z]+ne)vAlA/$1 vAlA/g;
            $word=~/([A-z]+ne)vAlA/g;
            $word=$1."\tunk";
            $word1="vAlA";
        }
        if($word=~/([A-z]+ne)vAle/) {
            # $word=~s/([A-z]+ne)vAle/g;
            $word=~/([A-z]+ne)vAle/g;
            $word=$1."\tunk";
            $word1="vAle";
        }

        if($word=~/([A-z]+ne)vAlI/) {
            #    $word=~s/([A-z]+ne)vAlI/$1 vAlI/g;
            $word=~/([A-z]+ne)vAlI/g;
            $word=$1."\tunk";
            $word1="vAlI";
        }
        if($word=~/([A-z]+ne)vAloM/) {
#        $word=~s/([A-z]+ne)vAloM/$1 vAloM/g;
            $word=~/([A-z]+ne)vAloM/g;
            $word=$1."\tunk";
            $word1="vAloM";
        }
        if($word=~/([0-9]+)([A-z]+)/) {
            $word=~/\t([0-9]+)([A-z]+)/g;
            $word=$1."\tunk";
            $word1=$2;
        }
        $result .= "1\t$word\n";
        if($word1 ne ""){
            $result .= "1\t$word1\tunk\n";
        }
    }
    return $result;
}

1;
