package hin::chunker;
use Data::Dumper;
use Exporter qw(import);
use IPC::Run qw(run);
use strict;
use warnings;

our @EXPORT = qw(chunker);

my @dispatch_seq = (
    "ssf2tnt",
    "crf_test",
    "bio2ssf"
);

sub bio2ssf {
    my %par = @_;
    my $data = $par{'data'};

    my $result = "";
    my $line = "";
    my $startFlag = 1;
    my $wno = 1;
    my $prevCTag = "";
    my $error = "";
    my $lno = 0;
    my $sno = 1;
    my $cno = 0;

    open INFILE, '<', \$data  or die $!;

    while (my $line = <INFILE>) {
        $lno ++;
        if ($line =~ /^\s*$/) {       # start of a sentence
            $result .= "\t))\t\t\n";
            $result .= "</Sentence>\n\n";
            $startFlag = 1;
            $wno = 1;
            $prevCTag = "";
            $sno ++;
            $cno = 0;
            next;
        }

        if ($startFlag == 1) {
            $result .= "<Sentence id=\"$sno\">\n";
        }
        chomp($line);
        my @cols = split(/\s+/,$line);

        if ($cols[3] =~ /^B-(\w+)/) {
            my $ctag = $1;
            if ($prevCTag ne "O" && $startFlag == 0) {
                $result .= "\t))\t\t\n";
                $wno++;
            }
            $cno++;
            $result .= "$cno\t((\t$ctag\t\n";
            $wno=1;
            $prevCTag = $ctag;
        } elsif ($cols[3] =~ /^O/) {
            if($prevCTag ne "O" && $startFlag == 0) {
                $result .= "\t))\t\t\n";
                $wno++;
            }
            $prevCTag = "O";
        }

        if ($cols[3] =~ /I-(\w+)/ ) {
            # check for inconsistencies .. does not form a chunk if there r inconsistencies
            my $ctag = $1;
            if ($ctag ne $prevCTag) {
                $error = $error . "Inconsistency of Chunk tag in I-$ctag at Line no:$lno : There is no B-$ctag to the prev. word\n";
            }
        }
        $cols[2] =~ s/___/ /g;
        $result .= "$cno.$wno\t$cols[0]\t$cols[1]\t$cols[2]\n";
        $wno ++;
        $startFlag = 0;
    }
    return $result;
}

sub crf_test {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    run ["/usr/local/bin/crf_test", "-m", "./lib/hin/chunker/models/300k_tokens.model"], \$data, \$result;
    return $result;
}

sub ssf2tnt {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open INFILE, '<', \$data  or die $!;
    while (my $line = <INFILE>) {
        chomp($line);
        if ($line=~/<\/S/) {
            $result .= "\n";
            next;
        }
        if ($line =~ /^\s*$/) {  # if the line has all space charcters
            $result .= "\n";
            next;
        }
        $line=~s/[ ]+/___/g;
        my ($att1,$att2,$att3,$att4) = split (/[\t]+/, $line);
        if ($att1 =~ /\<.*/ || $att2 eq "((" || $att2 eq "))") { #unwanted lines
            next;
        } else {
            $result .= "$att2\t$att3\t$att4\n";
        }
    }
    return $result;
}

sub chunker {
    my %args = @_;
    utf8::encode($args{"data"});
    foreach my $submodule (@dispatch_seq) {
        $args{'data'} = __PACKAGE__->can($submodule)->(%args);
    }
    utf8::decode($args{"data"});
    return $args{"data"};
}

1;
