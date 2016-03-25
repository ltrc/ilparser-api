package ilparser;
use Config::IniFiles;
use Data::Dumper;
use strict;
use warnings;

my %parser_table;

sub new_parser {
    my $class = shift;
    my $self = {
        lang => shift,
        daemons => {}
    };

    # Register this module as a parser service
    $parser_table{$self->{lang}} = shift;

    bless $self, $class;
    return $self;
}

sub register_daemons {
    my ($self, $config) = @_;
    my %dhash;
    tie %dhash, 'Config::IniFiles', (-file => $config);
    $self->{daemons} = \%dhash;
}

sub run_daemon {
    my ($self, $daemon_name) = @_;
    my %daemon = %{$self->{daemons}{$daemon_name}};
    my $cmd = "$daemon{path} $daemon{args} $daemon{port} &";
    system("flock -e -w 0.01 ./run/${daemon_name}_$daemon{port} -c '$cmd'") == 0
        or warn "[${daemon_name}_$self->{lang}]: Port $daemon{port} maybe unavailable! $?\n";
}

sub call_daemon {
    my ($self, $daemon_name, $input) = @_;
    my $port = $self->{daemons}{$daemon_name}{port};
    my ($socket, $client_socket);
    $socket = new IO::Socket::INET (
        PeerHost => '127.0.0.1',
        PeerPort => $port,
        Proto => 'tcp',
    ) or die "ERROR in Socket Creation : $!\n";
    $socket->send("$input\n");
    #local $/ = "\x{00}";
    my $result = "";
    while (my $line = $socket->getline) {
        $result .= $line;
    }
    $socket->close();
    return $result;
}

sub initialize_langs {
    foreach my $lang (keys %parser_table) {
        $parser_table{$lang}->init();
    }
}

sub get_parser {
    my $lang = shift;
    return $parser_table{$lang};
}

1;
