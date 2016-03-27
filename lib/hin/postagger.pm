package hin::postagger;
use Data::Dumper;
use Dir::Self;
use Exporter qw(import);
use IPC::Run qw(run);
use strict;
use warnings;

our @EXPORT = qw(postagger);

my @dispatch_seq = (
    "ssf2tnt",
    "extra_features",
    "crf_test",
    "split",
    "tnt2ssf"
);

sub crf_test {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    run ["/usr/local/bin/crf_test", "-m", __DIR__ . "/postagger/models/300k_tokens.model"], \$data, \$result;
    return $result;
}

sub extra_features {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open INFILE, '<', \$data  or die $!;
    while (my $line = <INFILE>) {
        chomp($line);
        if ($line =~ /^\s*$/) { # if the line has all space charcters
            $result .= "\n";
            next;
        }
        my ($att1, $att2) = split (/\s+/, $line);
        $result .= "$att1 ";
        my @array = split(//,$att1);
        my $len = @array;
        if ($len  < 3) { # if the length of the word is less than 3 print LESS
            $result .= "LESS ";
        } else {
            $result .= "MORE ";
        }
        if ($len >= 4) { # if the length of the word is less than 4 print LL which mean its not defined else print the last four charcters of the word
            $result .= $array[-4];
            $result .= $array[-3];
            $result .= $array[-2];
            $result .= $array[-1];
        } else  {
            $result .= "LL"; # here LL means not defined
        }
        $result .= " ";
        if ($len >= 3 ) {
            $result .= $array[-3];
            $result .= $array[-2];
            $result .= $array[-1];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        if ($len >= 2) {
            $result .= $array[-2];
            $result .= $array[-1];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        $result .= $array[-1];
        $result .= " ";
        if ($len >= 7) {
            $result .= $array[0];
            $result .= $array[1];
            $result .= $array[2];
            $result .= $array[3];
            $result .= $array[4];
            $result .= $array[5];
            $result .= $array[6];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        if ($len >= 6) {
            $result .= $array[0];
            $result .= $array[1];
            $result .= $array[2];
            $result .= $array[3];
            $result .= $array[4];
            $result .= $array[5];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        if ($len >= 5) {
            $result .= $array[0];
            $result .= $array[1];
            $result .= $array[2];
            $result .= $array[3];
            $result .= $array[4];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        if ($len >= 4) {
            $result .= $array[0];
            $result .= $array[1];
            $result .= $array[2];
            $result .= $array[3];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        if ($len >= 3) {
            $result .= $array[0];
            $result .= $array[1];
            $result .= $array[2];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        if ($len >= 2) {
            $result .= $array[0];
            $result .= $array[1];
        } else {
            $result .= "LL";
        }
        $result .= " ";
        $result .= $array[0]; # so overall printing the first 1-7 charcters and last 1-4 charcters
        $result .= " ";
        $result .= "$att2\n";
    }
    return $result;
}

sub postagger {
    my %args = @_;
    utf8::encode($args{"data"});
    foreach my $submodule (@dispatch_seq) {
        $args{'data'} = __PACKAGE__->can($submodule)->(%args);
    }
    utf8::decode($args{"data"});
    return $args{"data"};
}

sub split {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open INFILE, '<', \$data  or die $!;
    while (my $line = <INFILE>) {
        chomp($line);
        my @array = split (/[ \t]+/, $line);
        $result .= @array ? "$array[0] $array[14] $array[13]\n" : "\n";
    }
    return $result;
}

sub ssf2tnt {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open INFILE, '<', \$data  or die $!;
    while (my $line = <INFILE>) {
        chomp($line);
        if($line =~ /^\s*$/) { # if the line has all space charcters
            $result .= "\n";
            next;
        }
        $line=~s/[ ]+/___/g;
        my ($att1,$att2,$att3,$att4) = split (/[\t]+/, $line);
        if ($att1 =~ /\<.*/ || $att2 eq "((" || $att2 eq "))") { #unwanted lines
            next;
        } else {
            $result .= "$att2\t$att4\n";
        }
    }
    return $result;
}

sub tnt2ssf {
    my %par = @_;
    my $data = $par{'data'};
    my $result = "";
    open INFILE, '<', \$data  or die $!;

    my $wno = 1;
    my $sno = 1;
    #scan each line from standard input
    while (my $line = <INFILE>) {
        if ($line =~ /^\s*$/) {
            $result .=  "</Sentence>\n";
            $sno ++;
            $wno = 1;
            next;
        }

        if ($wno == 1) {
            $result .= "<Sentence id=\"$sno\">\n";
        }

        chomp($line);

        my @cols = split(/[ ]+/,$line);
        $cols[2]=~s/___/ /g;
        $result .= "$wno\t$cols[0]\t$cols[1]\t$cols[2]\n";
        $wno ++;
    }
    return $result;
}

1;
